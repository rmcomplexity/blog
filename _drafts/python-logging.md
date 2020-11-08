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

Logging is one of the best ways to keep track of what is going on inside your code while
it is running. Python comes with a very powerful logging library but with great power..
things start to get a bit complicated.

Logs can also help us keep track of key metrics and eventually visualize them.
Let's start with a quick overview of Python's logging library.

## What is `basicConfig`?

Following Python's philosophies the logging library can be easily used, for example:

```python
import logging
logging.warning("Warning log message.")
```

And that's it. The example above will print a log message with `WARNING` level.
If you run the code above you will see this output:

```shell
WARNING:root:Warning log message.
```

Take a look at what is printed before our message: `WARNING:root:`, this comes from
the default logging configuration. The default configuration
will only print [`WARNING` and above levels][logging-levels] and will prepend
the log level and the name of the logger -- *since we haven't created any loggers
the `root` logger is used. More on this later* --. The format each log message uses
can be configured and there is a lot of useful information readily available
when formatting. For each log event there is an instance of [`LogRecord`][logrecord-attrs].

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
[class' attributes][logrecord-attrs] and `%`-style formatting -- *`%`-style formatting is still
used to maintain backwards compatibility* --.
Since Python 3.2 we can also use `$` and `{}` style to format messages,
but we have to specify the style we're using, by default `%`-style is used.
The style is configured by using the `style` parameter in `basicConfig`
(`logging.basicConfig(style='{')`).
With the updated configuration we can now see every log level message, for example:

```python
[CRITICAL]:9 - Critical log message.
[ERROR]:10 - Error log message.
[WARNING]:11 - Warning log message.
[INFO]:12 - Info log message.
[DEBUG]:13 - Debug log message.
```

<blockquote>
  <i class="fas fa-quote-left fa-2x">&nbsp;</i>
  <p>
   <strong>Best Practice</strong><br />
   Define a custom log format for easier log parsing.
  </p>
  <i class="fas fa-quote-right fa-2x">&nbsp;</i>
</blockquote>

> **Note:** Use the `LogRecord` [class' attributes][logrecord-attrs] to configure a custom format.

`basicConfig` will always be called by the root logger if no handlers are defined,
unless the parameter `force` is set to `True` (`logging.basicConfig(force=True)`).
By default `basicConfig` will configure the root logger to output logs to `stdout`,
with the default format of `{level}:{logger_name}:{message}`.

## Custom Loggers

In the past examples we've been using the `root` logger, but python's logging library
allow us to create custom loggers which will *always* be children of the `root` logger.
We can create a new logger by using [`logging.getLogger("mylogger")`][get-logger],
this method only accepts one parameter, the `name` of the logger. `getLogger` is a
*get_or_create* method. It is pretty cheap to create a logger so we don't have to
pass around logger objects. We can use `getLogger` with the same `name`
value and we'll be working with the same logger configuration regardless if
we're doing this in a different class or module.

The name of the logger is important because the logging library uses dot notation to
create hierarchies of loggers. Meaning, if we create three loggers with the names
`app`, `app.models` and `app.api` the parent logger will be `app` and,
`app.db` and `app.api` will be the children. Here's a visual representation:

```bash
 + app # main logger
 |
 + app.api # api logger, child of "app" logger
   |
   - app.api.routes # routes logger, child of "app" and "app.api" loggers
   |
   - app.api.models # models logger, sibling of "app.api.routes" logger
 |
 - app.utils # utils logger, sibling of "app.api" logger
 ```

A good thing to remember is that we can get a module's dot
notation name from the global variable `__name__`. Using `__name__` to create
our custom loggers simplifies configuration and avoids collisions:

```python
# project/api/utils.py

import logging

LOG = logging.getLogger(__name__)

def check_if_true(var):
    """Check if variable is `True`.

    :param bool var: Variable to check.
    :return bool: True if `var` is truthy.
    """
    LOG.info("This logger's name is 'project.api.utils'.")
    return bool(var)
```

> **Note:**
>   If you are defining loggers at the module level (like the example above)
>   is better to stick to global variable naming. Meaning, use `LOG` or `LOGGER`
>   instead of the lowercase version `log` or `logger`.

<blockquote>
  <i class="fas fa-quote-left fa-2x">&nbsp;</i>
  <p>
   <strong>Best Practice</strong><br />
   Create loggers with custom names using `__name__` to avoid collision and for
   granular configuration.
  </p>
  <i class="fas fa-quote-right fa-2x">&nbsp;</i>
</blockquote>

Keeping in mind there's a logger hierarchy is a good idea because of how log messages are
passed around. When using a logger the message's level is checked against the logger's
`level` attribute if it's the same or above then the log message is passed to the logger
that's being used and every parent **unless** one of the logger in the hierarchy sets
`propagate` to `False` -- *by default `propagate` is set to `True`* --.

## How to configure loggers

We've talked about using `basicConfig` to configure the root logger but there are [other
ways][logging-config-options] to configure custom logger.
The most popular way of logging configuration is using a
[`dictConfig`][logging-dictconfig]. The examples in this article will
show three different variations (code, `fileConfig` and `dictConfig`),
feel free to use whatever is better for your project.

Python's logging is build in a modular manner.
A **logger** is the interface our application will use and consists of
**formatters**, **filters** and **handlers**. As we learned before python's logging
library already comes with some useful default values which makes defining our own
formatters, filters and handlers optional. As a matter of fact when using a
dictionary to configure logging the only required key is `version`, and currently
the only valid value is `1`.

<blockquote>
  <i class="fas fa-quote-left fa-2x">&nbsp;</i>
  <p>
    <strong>Suggestion</strong><br/>
    Defining custom <strong>filters</strong> and <strong>handlers</strong> is not necessary and should only be done
    if necessary.
  </p>
  <i class="fas fa-quote-right fa-2x">&nbsp;</i>
</blockquote>

Whenever we use a logger (`LOG.debug("Debug log message.")`) the first thing that happens
is that a `LogRecord` object is created with our log message and other
[attributes][logrecord-attrs]. This `LogRecord` instance is then passed to any **filters**
attached to the logger instance we used. If the filter does not reject the `LogRecord`
instance then the `LogRecord` is passed to the configured **handlers**.
If any of the configured **handlers** are enable for the level in the passed `LogRecord`
then the **handlers** apply any configured **filters** to the `LogRecord`.
Finally, if the `LogRecord` is not rejected by any of the **filter** the `LogRecord`
is emitted. A more detailed diagram can be seen in [python's documentation][logging-flow].

To simplify Python's logging flow we can focus on what happens in a single logger:

#### Python logging flow simplified

<figure class="img center">
  <img src="/assets/images/Python_logging_flow_simplified-1.jpg"
       style="max-width:200px;"
       alt="Python logging flow simplified"
       class="img-responsive">
  <figcaption><em>That snake is even more impressive in real life</em></figcaption>
</figure>

Here's a few important things to note:

- The previous diagram is from the logger that is being used point of view.
- Filters, handlers and formatters are defined once and can
be used multiple times.
- **Only** the filters and formatters assigned to the parent's
  handler are applied to the `LogRecord`.

**There are four reason why a logger would not process a log event**:

- The logger or the handler configured in the logger are not enabled
  for the log level used.
- A filter configured wither in the logger or the handler rejects
  the log event.
- A child logger does has `prooagate=False` causing events not to be passed
  to any of the parent loggers.
- Your are using a different logger or the logger is not a parent of the
  one being used.

### Formatters

A [formatter object][formatter-object] transforms a
`LogRecord` instance into a human readable string or a string that will be consumed
by an external service. We can use any [`LogRecord` attribute][logrecord-attrs]
or anything sent in the logging call as the `extra` parameter.

> **Note**
> Formatter can only be set to **handlers**

For example, we can create a formatter to show all the details of where and when
a log message happened:

##### Formatters definition using a dictionary

```python
LOGGING_CONFIG = {
    "version": 1,
    "formatters": {
        "detailed": {
            "format": "[APP] %(levelname)s %(asctime)s %(module)s "
                      "%(name)s.%(funcName)s:%(lineno)s: %(message)s"
        }
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "detailed",
            "level": "INFO"
        }
    }
}
```

##### Formatters definition using code

```python
import sys
import logging

# create Formatter
formatter = logging.Formatter(
    "[APP] %(levelname)s %(asctime)s %(module)s "
    "%(name)s.%(funcName)s:%(lineno)s: %(message)s"
)
stream_handler = logging.StreamHandler(sys.stdout)
stream_handler.setFormatter(formatter)
```

##### Formatters definition using a file

```ini
[formatters]
key=detailed

[handlers]
key=console

[formatter_detailed]
format=[APP] %(levelname)s %(asctime)s %(module)s %(name)s.%(funcName)s:%(lineno)s: %(message)s
datefmt=
class=logging.Formatter

[handler_console]
class=StreamHandler
level=DEBUG
formatter=detailed
args=(sys.stdout,)
```
Whenever this formatted is used it will print the level, date and time,
module name, function name, line number and any string sent as parameter.
We can add other variables not present in `LogRecord`'s attributes by using
the `extra` attribute:

```python
LOGGING_CONFIG = {
    "version": 1,
    "formatters": {
        "short": {
            "format": "[APP] %(levelname)s %(asctime)s %(module)s "
                      "%(name)s.%(funcName)s:%(lineno)s: "
                      "[%(session_key)s:%(user_id)s] %(message)s" # add extra data
        }
    },
    #[...]
}
```

And to send that extra data we can do it like this:

```python
# app.api.UserManager.list_users

LOG.info(
    "Listing users",
    extra={"session_key": session_key, "user_id": user_id}
)
```

The output would be:

```bash
[APP] INFO 2020-11-07 20:47:00,123 user_manager app.api.user_name.list_users:15 [123abcd:api_usr] Listing users
```

The downside of referencing variables sent via the `extra` parameter
in a format is that if the variable is not passed the log event is
not going to be logged because the string cannot be created.

<blockquote>
  <i class="fas fa-quote-left fa-2x">&nbsp;</i>
  <p>
    <strong>Best Practice</strong><br/>
    Make sure to send every additional variable that the configured
    formatter references if using the `extra` parameter 
  </p>
  <i class="fas fa-quote-right fa-2x">&nbsp;</i>
</blockquote>

### Filters

Filters are very interesting. They can be used both at the logger level
or at the handler level, they can be used to stop certain log events from
being logged and they can also be used to inject additional context into
a `LogRecord` instance which will be, eventually, logged.

The `Filter` class in Python's `logging` library filters `LogRecords` by
logger name. The filter will allow any `LogRecord` coming from the logger name
configured in the filter and any of it's children.
If we have these loggers configured:

```
 + app.models
 | |
 | - app.models.users
 |
 + app.views
   |
   - app.views.users
   |
   - app.views.products
```

And we can define the config like this:

##### Filters definition using a dictionary

```python
LOGGING_CONFIG = {
    "version": 1,
    "filter": {
        "views": {
            "name": "app.views"
        }
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "level": "INFO",
            "filter": "views"
        }
    },
    "loggers": {
        "app": { "handlers": ["console"] }
    }
}
```

##### Filters definition using code

##### Filters definition using a file

The previous configuration will **only** allow `LogRecord` the
`app.views`, `app.views.users` and `app.views.products`
loggers. Note that if you are using `__name__` to instantiate loggers
then this is the same as saying that the filter will allow any `LogRecord`
comming from the `app.view` module or any of it's children.

When you set a filter to a specific logger the filter will **only** be used
when calling that logger directly and **not** when a descendant of said logger
is used. For example, if we had set the filter in the previous example to the
`app.view` logger instead of the `app` logger handler. The filter will not
reject any `LogRecord` coming from `app.models` loggers simply because when
using the logger `app.models`, or any of it's childrens, the filter will not be called.
Here is how the config would look like in this example.

Now that we have seen the difference between setting a filter to a logger and to
a handler, and how can a filter reject `LogRecords` we'll see how can we create custom
filters to prevent `LogRecords` to be dismissed based on more complicated conditions
and/or to add more data to a `LogRecord`.


Writing a custom filter is very simple. **Before to Python `3.2`**
we have to subclass `logging.Filter`` and override the `filter` method:

```python
import logging

class CustomFilter(logging.Filter)
    def __init__(self, name):
        super(self, CustomFilter)

    def filter(self, record):
        # do some cool filtering here
        # return a Truthy value if you want the
        # log record to go through
```

**Since Python 3.2** you can use any callable that accepts a `record` parameter

```python
def custom_filter(record):
    # do some cool filtering here
    # return a Truthy value if you want the
    # log record to go through
```

The way to configure these custom classes/callables using a dictionary or a file
is by using the special keyword `()`. Whenever Python's logging config sees
`()` it will create an instance of the class (dot notation has to be used).

> **Note**
> When using a dictionary to configure logging you can use the `()`
> keyword to configure custom handlers or filters

Another interesting thing about filters is that they see virtually every `LogRecord`
that *might* be logged. This makes filter a great place to further customize `LogRecords`

##### Custom filter example

The following custom filter will apply a mask to every password passes to a `LogRecord`

```python
def pwd_mask_filter(record)
    # a Logger cord instance holds all it's arguments in record.args
    def mask_pwd():
        return '*' * 20

    if record.args.has_key("pwd"):
        record.args["pwd"] = mask_pwd()
```

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
[get-logger]: https://docs.python.org/3/library/logging.html#logging.getLogger
[logging-flow]: https://docs.python.org/3/howto/logging.html#logging-flow
[formatter-object]: https://docs.python.org/3/library/logging.html#formatter-objects
