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
it is running. Python comes with a very powerful logging library but with great power..
things start to get a bit complicated. On top of all the different things one can
do with Python's logging library we also have to take into consideration other
technologies used in a project such as Django and Docker.

Logs can also help us keep track of key metrics and eventually visualize them.

Let's start with a quick overview of Python's logging library.

## What is `BasicConfig`?

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

## Custom Loggers

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

LOG = logging.getLogger(__name__)

def check_if_true(var):
    """Check if variable is `True`.

    :param bool var: Variable to check.
    :return bool: True if `var` is truthy.
    """
    LOG.info("This logger's name is 'project.api.utils'.")
    return bool(var)
```

> **Best Practice:**
>   Create loggers with custom names using `__name__` to avoid collision and for
>   granular configuration.

Keeping in mind there's a logger hierarchy is a good idea because of how log messages are
passed around. When using a logger the message's level is checked against the logger's
`level` attribute if it's the same or above then the log message is passed to the logger
that's being used and every parent **unless** one of the logger in the hierarchy sets
`propagate` to `False` -- *by default `propagate` is set to `True`* --. We'll explore
this concept more in the next section.

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
