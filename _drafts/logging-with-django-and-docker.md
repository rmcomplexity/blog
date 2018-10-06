---
layout: post
title:  "Tales From The Keyboard: Logging with Django and Docker"
date:   2018-05-01 10:00:00 -0600
categories: article
excerpt: Logging in python is a very powerful feature, when using Django a few
    things are different and by adding Docker on top logging can become a
    handful. We'll go through some real world examples and recommendations.
tags: 
  - Python
  - Logging
  - Django
  - Docker
seo:
  type: Article
author_name: Josue Balandrano Coronel
author: rmcomplexity
image: /assets/images/logging_with_django_and_docker/logging-with-django-and-docker.png
---

Setting up logging on a project can seem like an overwhelming task and some times
frustration comes into place when we can't quite configure it the way we want. In this
article we'll go through some real world examples to better understand how can we setup
and use logging with Python, Django and Docker.

Logging is one of the best ways to keep track of what is going on inside your code while
it is running. Python comes with a very powerful logging library but with great power
things can start to get a bit complicated. On top of all the different things one can
do with Python's logging library we also have to take into consideration other
technologies used in a project such as Django and Docker.

Most of the projects we work here at the [Texas Advanced Computing Center (TACC)][tacc]
have multiple stakeholders. Metrics and reports are an imperative element for our
stakeholders and we create some of these reports from our logs using [splunk][splunk].
Let's start with a quick overview of Python's logging library.

## Logging With Python

Following Python's philosophies the logging library can be easily used, for example:

```python
import logging
logging.warning("Warning log message.")
```

And that's it. The example above will print a log message with `WARNING` level.
If you run the previous script you will see an output such as:

```shell
WARNING:root:Warning log message.
```

An interesting thing happens if we try to print an `INFO` or `DEBUG` log message.
We do not see anything on the output if we try to use `logging.info("Info log message.")`.
Another thing to note here is what is printed before our message: `WARNING:root:`. The
reason for this is the default logging configuration. The default configuration
will only print [`WARNING` and above levels][logging-levels] and will prepend
the log level and the name of the logger -- *since we haven't created any loggers
the `root` logger is used. More on this later* --. The format each log message uses
can be configured and there is a lot of useful information readily available
when formatting. For each log event there is an instance of `LogRecord`.

The easiest way to configure the logging format is [using `basicConfig`][basic-config].
For instance, if we would like to print only the log level, line number, log message
and log `DEBUG` events and up we can do this:

```python
import logging
logging.basicConfig(
    format="[%(levelname)s]:%(lineno)s - %(message)s",
    level=logging.DEBUG
)
```

We can set the format for our log messages using the `LogRecord`
[class' attributes][logrecord-attrs] and %-style formatting -- *%-style formatting is still
used to maintain backwards compatibility* --. Since Python 3.2 we can also use `${}` and `{}`
style to format messages, but we have to specify the style we're using, by default %-style is used.
With the updated configuration we can now see every log level message, for example:

```python
[CRITICAL]:9 - Critical log message.
[ERROR]:10 - Error log message.
[WARNING]:11 - Warning log message.
[INFO]:12 - Info log message.
[DEBUG]:13 - Debug log message.
```

> **Best Practice:**
>   Define a custom log format for easier log parsing.

> **Note:** Use the `LogRecord` [class' attributes][logrecord-attrs] to configure a custom format.

In the past examples we've been using the `root` logger, but python's logging library
allow us to create custom loggers which will *always* be children of the `root` logger.
We can create a new logger by using `logging.getLogger("mylogger")`, this method
only accepts one parameter, the `name` of the logger. Note `getLogger` is a
*get_or_create* method. It is pretty cheap to create a logger and there is no
need to pass around a logger object. We can use `getLogger` with the same `name`
value and we'll be working with the same logger configuration regardless if
we're doing this in a different class or module.

The name of the logger is important because the logging library uses dot notation to
create hierarchies of loggers. Meaning, if we create three loggers with the names
`app`, `app.db` and `app.api` the parent logger will be `app` and, `app.db` and `app.api`
will be the children. A good thing to remember is that we can get a module's dot
notation name from the global variable `__name__`. Using `__name__` to create
our custom loggers simplifies configuration and avoids collisions:

```python
# project/api/utils.py

import logging

def check_if_true(var):
    """Check if variable is `True`.

    :param bool var: Variable to check.
    :return bool: True if `var` is truthy.
    """
    logger = logging.getLogger(__name__)
    logger.info("This logger's name is 'project.api.utils'.")
    return bool(var)
```

> **Best Practice:**
>   Create loggers with custom names using `__name__` to avoid collision and for
>   granullar configuration.

Keeping in mind there's a logger hierarchy is a good idea because of how log messages are
passed around. When using a logger the message's level is checked against the logger's
`level` attribute if it's the same or above then the log message is passed to the logger
that's being used and every parent **unless** one of the logger in the hierarchy sets
`propagate` to `False` -- *by default `propagate` is set to `True`* --. We'll explore
this concept more in the next section.

## Logging in Django [And Other Applications]

Django uses python's standard logging library which makes things way easier.
We've talked about using `basicConfig` to configure logging but there are [other
ways][logging-config-options] to do this. By default Django will
[use `dictConfig`][logging-dictconfig] to configure a project's logging.
If we want to configure this further we have to set a value to Django's
`LOGGING` setting variable. The value has to be a dictionary based on the
[configuration dictionary schema][logging-dictconfig]. Everything in this section
can also be applied to any python project as well as a Django project.

> **Best Practice:**
>   Using a dictionary to configure logging is more readable and easier to write.
>   A JSON or YAML file can be parsed into a dictionary.

When I first started diving into seriously tweaking logging in a project it was
confusing to me how everything defined by the dictionary came into place.
We first have to remember that python's logging is build in a modular manner.
A **logger** is the interface our application will use and consists of
**formatters**, **filters** and **handlers**. As we learned before python's logging
library already comes with some useful default which makes defining our own
formatters, filters and handlers optional. As a matter of fact when using a
dictionary to configure logging the only required key is `version`, and currently
the only valid value is `1`.

But let's not stop there, another key we usually
see on different examples and even in Django's documentation is
`disable_existing_loggers`. Honestly, I used `disable_existing_loggers` multiple times
without really knowing what it does. `disable_existing_loggers`
will make any previously defined loggers to not do anything.
It is recommend to set this value to `False` -- *by default this value is `True`
when using `fileConfig` or `dictConfig`* --. The reason to set `disable_existing_loggers`
to `False` is we can use `getLogger` anywhere in our code, and we usually see it
being used either at the module level or at the class/function level.
Since creating a logger is cheap it is recommended to not use `getLogger` at
the module level. Although, it is easier to create a logger at the top of a
module this can introduce issues when configuring loggers. For example,
say we have a module that logs some message such as:

```python
# app/client.py
import logging

LOGGER = logging.getLogger(__name__)

class Client:
    """App Client."""

    def __init__(name):
        """Custom App Client.

        :param str name: Client's name
        """
        LOGGER.info(
            "instantiating client with name: %s",
            name
        )
```

And, we use this module on the app's entry point which configures the loggers
used throughout the application:

```python
# app/__main__.py
import logging
from app.client import Client

LOGGING = {
    "version": 1,
    "formatters": {
        "short": {
            "format": "[APP] %(levelname)s %(asctime)s %(module)s "
                      "%(name)s.%(funcName)s:%(lineno)s: %(message)s"
        }
    },
    "handlers": {
        "standard": {
            "class": "logging.StreamHandler",
            "formatter": "short",
            "level": "INFO"
        }
    },
    "loggers": {
        "app": {
            "handlers": ["standard"],
            "level": "DEBUG"
        }
    }
}

logging.config.dictConfig(LOGGING)

if __name__ == "__main__":
    client = Client()
    #do some more cool things.
```

We would expect for our log message from `app.client.Client` to be printed to the
standard output and using the defined format but this is not going to happen.
In our app's entry point we are importing the `app.client` module which creates
the logger that we use within the `Client` class. This import happens before
we use `dictConfig` which will disable any existent loggers by default.
This is the reason why if we create our loggers at the module level we must
remember to set `disable_existing_loggers` to `False`.

> **Best Practice:**
>   Set `disable_existing_loggers` to `False` when creating loggers at the module level.

We've taken a look at a more complete logging configuration in the past example.
The example defines **formatters** and **handlers** as well as a **logger**.
We've also talked about formatters in previous examples. After configuring logging in
multiple projects I've gathered a few recommendations that have helped me:

> **Formatters Best Practices:**
> 1. Add an explicit and easily identifiable prefix on any custom formatters.
    For instance, in the previous example we use `[APP]`. This prefix facilitates
    information extraction from logs using tools like `grep` and `awk` or even more
    advanced software packages like splunk. It can also help when configuring
    [logstash filters][logstash].
> 2. Define multiple formatters. What has worked for me is to have three different
    formatters. One with a long format, another with a short format (usually using only
    `levelname`, `name`, `funcName`, `lineno` and `message`) and a third one which we
    use to log metrics.
> 3. Specify the format style used (by default %-style is configured, e.g. `logger.info("Username: %s", username)`,
    this allow python's logging library to be more efficient when creating log records
    since the message string will be evaluated when printing the message. Avoid formatting
    messages by hand, e.g. `logger.debug("Username: {username}".format(username=username))`.

Let me explain what I meant about logging metrics. As I mentioned before in most, if not all, of the
projects we work here at [TACC][tacc] there are multiple stakeholders which have to report back
usage metrics to institutions who have given them a grant (e.g. [NSF][nfs]). Since we have splunk
hosted in-house we prefer to use it when creating reports. Using logs data to create reports takes
a lot of pressure from the application since we don't have to worry about saving metrics data
in a database and we only have to worry about correctly configure logging and use the correct
log levels. This has worked great for us and I do recommend looking into different log processing
tools to create reports.

> **Best Practice:**
>   Always use the correct log level, e.g. `CRITICAL`, `WARNING`, `INFO`, etc.
>   Even when this means taking a few extra minutes to think about what would be the correct level
>   to log a particular message.

> **Best Practice:**
>   When creating `ERROR` level messages use `exc_info=True`, e.g. `logger.error("Invalid
>   action for view.", exc_info=True)`. This will print the error message as well as the
>   stacktrace, which is always helpful.

The next object to take a look is **handlers**. A handler is in charge to [optionally ] define
a format and a filter. Python offers many [useful handler classes][logging-handlers] already which
makes unnecessary to create custom handler classes, most of the cases that is -- **this article
will not touch on creating custom handler classes. That's a topic for another article** --. It is not
necessary to configure handlers for every logger since messages are propagated to any parent loggers.
We could easily define and configure handlers for all top level loggers, but it is recommended to
specify all the handlers used by every logger for better readability. Another thing to notice is that
we can also define a `level` on each handler. At first seeing `level` in both the `logger` and
`handler` definition confused me and I opted to always use the same value in both places. Using
the same value is a good way to keep your configuration simple but it is important to understand
what we can do with this. A logger will pass a message to its handlers if the log message is, at least,
the same level that is configured in that specific logger. When the message it passed to the handlers
-- **there can be more than one handler configured for a logger** -- each handler will also check the level
of the message and process the message only if it has the correct level. The use of multiple handlers
can be explained if we would like to use different destinations for `INFO` [and up] messages and `DEBUG`
[and up] messages. We can create only one logger for our project and define two handlers to handle
each type of messages. Let's take a look at a more complete logging configuration used in a
Django project:

```python
# settings.py

LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "long": {
            "format": "[DJANGO] {levelname} {asctime} {module} "
                      "{name}.{funcName}:{lineno:d}: {message}"
            "style": "{"
        },
        "short": {
            "format": "[DJANGO] {levelname}: {message}"
            "style": "{"
        }
    },
    "filters": {
        "debug_true": {
            "()": "django.utils.log.RequireDebugTrue"
        },
        "debug_false": {
            "()": "django.utils.log.RequireDebugFalse"
        }
    },
    "handlers": {
        "console": {
            "level": "INFO",
            "class": "logging.StreamHandler"
            "formatter": "short",
            "filters": ["debug_false"]
        },
        "console_debug": {
            "level": "DEBUG",
            "class": "logging.StreamHandler"
            "formatter": "long",
            "filters": ["debug_true"]
        }
    },
    "loggers": {
        "django": {
            "handlers": ["console"],
            "level": INFO
        },
        "portal": {
            "handlers": ["console", "console_debug"],
            "level": "DEBUG"
        }
    }
}
```

There's a few new things in the last example:

First, we changed from %-style to {-style to
define our format. There is not any major benefits between styles other than {-style can only
be used from Python 3.2 over.

Second, we are defining a couple of filters and we are using filter classes offered by Django. 
Filters can be used to implement more complicated criteria to check whether the message should
be processed or not. Also, we can use filters to manipulate log records by adding context or
removing data. I have learned that it is better to keep filter usage to a minimal and I tend to
only use these two Django filter classes. Another interesting thing about this configuration
is the use of a `"()"` key within a filter. Whenever we can use a dictionary to configure an object,
i.e. Using a dictionary as the value for a key, we can use the special key `"()"`. This key allow us
to specify a custom class and, optionally, custom parameters for initialization. In the previous
example we are telling python's logging library to use the specified class. If we take a look at
the [Django filter classes][django-filter-classes] the only requirement is to define a `filter` method.

Third, we are defining two handlers and both of them are using `logging.StreamHandler`. This handler
class will use `stdout`/`stderr` to print log messages, which is simple and recommended. The first
handler uses the `"short"` format and will only process messages **if** the message has level `INFO`
or above **and** Django's `DEBUG` setting value is `False`. The second handler uses the `"long"` format
and will only process messages **if** the message has level `DEBUG` or above **and** Django's 
`DEBUG` setting value is `True`. This is a very useful setup for handlers since it will print
everything into the standard output and when we have `DEBUG=True` it will print more information for
every message. When we are in production and `DEBUG=False` it will only print the log level and
the message.

> **Handlers Best Practices:**
> 1. Explicitly define which handlers each logger will use in your configuration for improved
    readability.
> 2. Avoid logging messages to anywhere else other than standard output, i.e. Only use
    `logging.StreamHandler`. It is easier to use 3rd party logging packages which will pick up
    messages from the standard output and then post-process it. For instance, it is recommended
    to use `rsyslog` or `rsyslog-ng` to route log messages to different services such as
    [logstash][logstash] or [splunk][splunk]
> 3. Specify the level on which each handler should act on for improved readability and to avoid
    odd behaivour.

Remember we talked about how loggers have a hierarchy based on the name's dot notation?
Well, in the last example we are defining two loggers. The first one's name is `"django"`.
This mean that it'll handle every message that comes from a logger which name starts with `"django."`
(notice the dot). If we keep to the best practice of creating loggers by using `__name__` that means
every message that comes from a module inside the Django package. The same thing with the second
logger `"portal"`.

Now, let's say we have an app in our `portal` project named `projects` and we
place this app in the path `portal/apps/projects`. A project is an object that a user can create
which points to a specific folder in a remote storage. Users can upload data to a project (it
is not necessary to fully understand what a project is and this is merely to give some context).
We would like to create a usage reports to analyze every time users list their projects and we
want to log every error that happens, too. First, configure our metrics logger for easier processing:

```python
# settings.py

# This snippet only shows the lines we're adding to the logging config
LOGGING = {,
    "formatters": {
        "metrics": {
            "format": "[METRICS] {levelname}: {message}"
            "style": "{"
        }
    }
# [...]
    "handlers": {
        "console_metrics": {
            "level": "INFO",
            "class": "logging.StreamHandler"
            "formatter": "metrics",
        }
    }
# [...]
    "loggers": {
        "metrics": {
            "handlers": ["console_metrics"],
            "level": "INFO"
        }
    }
}
```

Then we retrieve our loggers and use them in our `views.py` file:

```python
# portal/apps/projects/views.py
import logging
from django.http import JsonResponse
from django.views.generic import View
from portal.apps.projects.models import Project

LOGGER = logging.getLogger(__name__)
METRICS = logging.getLogger(f"metrics.{__name__}")

class ProjectsListView(View):
    """Projects List View."""

    def get(self, request):
        """Return a list of projects."""

        try:
            prjs_list = Project.list(request.user)
        except Project.ObjectDoesNotExist as exc:
            LOGGER.error(exc, exc_info=True)
            return JsonResponse(
                status=500,
                "response": {
                    "message": exc
                }
            )

        # print log message for metrics
        METRICS.info(
            "Project list. username={username}",
            username=request.user.username
        )
        return JsonResponse(
            "response": prj_list
        )
```

In this example we have configured a second logger with a format that prefixes every message with
`"[METRICS]"`. In order to use it and be able to use the correct module name we prepend the string
`"metrics"` when getting the logger. Notice how we use a try/catch block to correctly log the
error with a stacktrace for furhter debugging. Now, let's say that we would like to only log
error messages for the `projects` app when we use the `LOGGER` object. we can add this to our
configuration:

```
# settings.py
LOGGIN = {
# [...]
    "loggers": {
        "portal.apps.projects": {
            "handlers": ["console", "console_debug"],
            "level": "ERROR"
        }
    }
}
```

With this update whenever we use the `LOGGER` object inside the `projects` app
(assuming it's correctly initialized using `__name__`) the message will be passed to the
`"portal.apps.projects"` logger. **If** the level is `ERROR` or above the message will be processed
and passed to the parent logger `"portal"`. This means that any log message only has **one** opportunity
to be completely discarded if the log level is incorrect. That is when it is passed to the first
logger. When the message is passed to any parent loggers every parent logger will check the message level
to see if it will process it and the message will continue to be passed up the hierarchy.
This hierarchy also means that the error message will be printed twice in the above case.
Once by the `"portal.apps.projects"` logger and once by the `"portal"` logger.
To avoid this we can set `propagate` to `False` in the `"portal.apps.projects"` logger. By setting
`propagate` to `False` we prevent the logger to pass the message up the hierarchy.

Another interesting usage of python's logging configuration is to configure library loggers.
Python's logging tutorial suggest to [use `logging.NullHandler`][null-handler] when setting up [logging in a
library][python-logging-for-library]. By using the null handler we let whomever is using the library
to configure the loggers if needed. Even if the library we're using does not use the null handler
we can configure the library's logger to, say, change the format.

A good example to overwrite the logging configuration for a library's logging: In one of the Django projects
I was working we had to ssh to a remote box using [paramiko][paramiko] and it was not working.
I went through the code over and over and couldn't figure our what the issue was. Finally,
I decided to overwrite the logging configuration by doing something like this:

```
#settings.py

LOGGING={
#[...]
    "paramiko": {
        "handlers": ["console"],
        "level": "DEBUG"
    }
}
```

The previous setup allowed me to see every debug message from the paramiko library on `stdout`
and allowed me to figure out that I was using an incorrect login handler for paramiko.

## Logging with Docker



* Docker Logs
    * Different logs
    * docker-compose logs
    * log drivers
* Django and Docker logging best practices

[python-howto-logging]: https://docs.python.org/3/howto/logging.html
[hitchhikers-logging]: https://docs.python-guide.org/writing/logging/
[docker-logging-drivers]: https://docs.docker.com/config/containers/logging/configure/
[tacc]: https://tacc.utexas.edu
[splunk]: https://www.splunk.com/
[logging-levels]: https://docs.python.org/3/library/logging.html#logging-levels
[logrecord-attrs]: https://docs.python.org/3/library/logging.html#logrecord-attributes
[basic-config]:https://docs.python.org/3/howto/logging.html#changing-the-format-of-displayed-messages
[logging-config-options]: https://docs.python.org/3/howto/logging.html#configuring-logging
[logging-dictconfig]: https://docs.python.org/3/library/logging.config.html#logging-config-dictschema
[logstash]: https://www.elastic.co/products/logstash
[nfs]: https://nsf.gov/
[logging-handlers]: https://docs.python.org/3/howto/logging.html#useful-handlers
[django-filter-classes]: https://github.com/django/django/blob/master/django/utils/log.py#L152
[python-logging-for-library]: https://docs.python.org/3/howto/logging.html#configuring-logging-for-a-library
[null-handler]: https://docs.python.org/3/library/logging.handlers.html#logging.NullHandler
[paramiko]: http://www.paramiko.org/
