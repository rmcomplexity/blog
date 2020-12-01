---
layout: post
title:  "Introduction to Python's logging library"
date:   2020-12-01 17:00:00 -0600
categories: article
excerpt: Logging is one of the best ways to keep track of what is going on inside your code while
    it is running. Python comes with a very powerful logging library but with great power...
    things start to get a bit complicated.
tags: 
  - Python
  - Logging
  - Fundamentals
seo:
  type: Article
author_name: Josue Balandrano Coronel
author: rmcomplexity
image: /assets/images/introduction_to_python_logging.png
---

* Table of Contents
{:toc}

Logging is one of the best way to keep track of what is going on inside your code while
it is running.  An error message can tell you details about the state
of the application when an error happens. But proper logging will make it easier to see
the state of the application right before the error happened or the path the data took
before the error happened.

**What's in this article?**

- Basic overview of Python's logging system.
- Explanation of how each logging module interact with each other.
- Examples on how to use different types of logging configurations.
- Things to look out for
- Recommendations for better logging

If you want you can jump to a [basic configuration](#what-is-basicconfig) example or
a [full fledged](#full-logging-configuration-example) example used in an application.

## The basics

At its simplest form a log message, in python is called a [`LogRecord`][logrecord-attrs],
has a string (the message) and a [level][logging-levels]. The level can be:

- `CRITICAL`: Any error that makes the application stop running.
- `ERROR`: General error messages.
- `WARNING`: General warning messages.
- `INFO`: General informational messages.
- `DEBUG`: Any messages needed for debugging.
- `NOTSET`: Default level used in handlers to process any of the above types of messages.


Python logging library has different modules. Not every module is necessary to start
logging messages.

- **Loggers:** the object that implements the main logging API. We use a logger to create
  logging events by using the corresponding level method, e.g. `my_logger.debug("my message")`.
  By default there's a root logger which can be configured using [`basicConfig`]() and we
  can also create [custom loggers](#custom-loggers).
- **Formatters:** [these objects](#formatters) are in charge of creating the correct representation of the logging
  event. Most of the time we ant to create a human-readable representation but in some cases we
  can output a specific format like a json object.
- **Filters:** We can use [filters](#filters) to avoid printing logging events based on more complicated
  criteria than logging levels. We can also use filters to modify logging events.
- **Handlers:** everything comes together in the [handlers](#handlers). A handler defines which formatters
  and filter a logger is going to use. A handler is also in charge of sending the loging output
  to the corresponding place,
  this could be `stdout`, `email` or almost anythihg else we can think of.


Loggers can have filters and handlers. Handlers can have filters and formatters.
We will dive into each one of these parts but it's a good idea to keep in mind how
they relate with each other. Here's a visual representation:

##### Python logger structure

<figure class="img center">
<a href="/assets/images/python_logger_structure.png">
  <img src="/assets/images/python_logger_structure.png"
       style="max-width:740px;"
       alt="Python logger structure"
       class="img-responsive">
  <figcaption><em>This reminds me of a cake, because of the layers.</em></figcaption>
</a>
</figure>

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

The first part of the output (`WARNING:root:`), comes from
the default logging configuration. The default configuration
will only print [`WARNING` and above levels][logging-levels] and will prepend
the log level and the name of the logger -- *since we haven't created any loggers
the `root` logger is used. More on this later* --.

The logger in the example above is the `root` logger. This is a logger which is
the parent of every logger that's created. Meaning, if you configure the `root`
logger then you are basically configuring every logger you create.

## What is `basicConfig`?

To quickly configure any loggers used in  your application you can use `basicConfig`.
This method will by default configure the root logger with a `StreamHandler` to print
log messages to `stdout` and a default formatter (like the one in the example above).

We can configure the logging format [using `basicConfig`][basic-config].
For instance, if we would like to print only the log level, line number, log message
and log `DEBUG` events and up we can do this:

```python
import logging
logging.basicConfig(
    format="[%(levelname)s]:%(lineno)s - %(message)s",
    level=logging.DEBUG
)
```

> <i class="fas fa-bolt">&nbsp;</i> **Note:** <br />
> By using `logging.basicConfig` we are configuring the root logger

For each log event there is an instance of [`LogRecord`][logrecord-attrs].
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

> <i class="fab fa-python">&nbsp;</i> **Best Practice** <br />
> Define a custom log format for easier log parsing.

> <i class="fas fa-bolt">&nbsp;</i> **Note:** <br />
> Use the `LogRecord` [class' attributes][logrecord-attrs] to configure a custom format.

`basicConfig` will always be called by the root logger if no handlers are defined,
unless the parameter `force` is set to `True` (`logging.basicConfig(force=True)`).
By default `basicConfig` will configure the root logger to output logs to `stdout`,
with the default format of `{level}:{logger_name}:{message}`.

## Custom Loggers

Python's logging library allow us to create custom loggers which will *always*
be children of the `root` logger.

We can create a new logger by using [`logging.getLogger("mylogger")`][get-logger].
This method only accepts one parameter, the `name` of the logger. `getLogger` is a
*get_or_create* method. We can use `getLogger` with the same `name`
value and we'll be working with the same logger configuration regardless if
we're doing this in a different class or module.

The logging library uses dot notation to
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

We can get a module's dot
notation name from the global variable `__name__`. Using `__name__` to create
our custom loggers simplifies configuration and avoids collisions:

```python
# project/api/utils.py

import logging

# Use __name__ to create module level loggers
LOG = logging.getLogger(__name__)

def check_if_true(var):
    """Check if variable is `True`.

    :param bool var: Variable to check.
    :return bool: True if `var` is truthy.
    """
    LOG.info("This logger's name is 'project.api.utils'.")
    return bool(var)
```

> <i class="fas fa-bolt">&nbsp;</i> **Note:**
>   If you are defining loggers at the module level (like the example above)
>   is better to stick to global variable naming. Meaning, use `LOG` or `LOGGER`
>   instead of the lowercase version `log` or `logger`.

> <i class="fab fa-python">&nbsp;</i> **Best Practice** <br />
> Create loggers with custom names using `__name__` to avoid collision and for
> granular configuration.

When using a logger the message's level is checked against the logger's
`level` attribute if it's the same or above then the log message is passed to the logger
that's being used and every parent **unless** one of the logger in the hierarchy sets
`propagate` to `False` -- *by default `propagate` is set to `True`* --.

## How to configure loggers, formatters, filters and handlers

We've talked about using `basicConfig` to configure a logger but there are [other
ways][logging-config-options] to configure loggers.
The recommended way of creating a logging configuration is using a
[`dictConfig`][logging-dictconfig]. The examples in this article will
show three different variations (code, `fileConfig` and `dictConfig`),
feel free to use whatever is better for your project.

As we've learned before python's logging
library already comes with some useful default values, which makes defining our own
formatters, filters and handlers optional. As a matter of fact when using a
dictionary to configure logging the only required key is `version`, and currently
the only valid value is `1`.

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
<a href="/assets/images/Python_logging_flow_simplified-1.jpg">
  <img src="/assets/images/Python_logging_flow_simplified-1.jpg"
       style="max-width:740px;"
       alt="Python logging flow simplified"
       class="img-responsive">
  <figcaption><em>Logger sounds like a cool frogger fork</em></figcaption>
</a>
</figure>

Here's a few important things to note:

- The diagram above is from the point of view of the logger used.
- Filters, handlers and formatters are defined once and can
be used multiple times.
- **Only** the filters and formatters assigned to the parent's
  handler are applied to the `LogRecord` (this is the loop that says "Parent Loggers\*")

##### Every log event created will be processed **except in the following cases**:

1. The logger or the handler configured in the logger are not enabled
  for the log level used.
2. A filter configured in the logger or the handler rejects
  the log event.
3. A child logger has `propagate=False` causing events not to be passed
  to any of the parent loggers.
4. Your are using a different logger or the logger is not a parent of the
  one being used.

### Formatters

A [formatter object][formatter-object] transforms a
`LogRecord` instance into a human readable string or a string that will be consumed
by an external service. We can use any [`LogRecord` attribute][logrecord-attrs]
or anything sent in the logging call as the `extra` parameter.

> <i class="fas fa-bolt">&nbsp;</i> **Note:**
> Formatters can only be set to **handlers**

For example, we can create a formatter to show all the details of where and when
a log message happened:

{::options parse_block_html="true" /}

<h5 class="toggler" data-cls="fmts-dict-config" data-default="true">
    Formatters definition using a dictionary
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="fmts-dict-config">
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

When using a dictionary to define a formatter we have to use the `"formatters"` key.
Any key inside the `"formatters"` object will become a formatter. Every inside the
formatter object will be sent as parameters when intializing the formatter instance.
</div>


<h5 class="toggler" data-cls="fmts-code">
    Formatters definition using code
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="fmts-code">
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

Initializing a formatter in code is straight forward. We have to remember to assign it
to a handler by using the handler's `setFormatter` method.
</div>


<h5 class="toggler" data-cls="fmts-file">
    Formatters definition using a file
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="fmts-file">
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

In a file configuration we first define the keys of the object we will be referencing.
In this case we create a `detailed` formatter. We then configure this formatter by creating a
`formatters_<formatter_key>` section, here will be `formatter_detailed`.
If `datefmt` is not defined the default ISO is used.
</div>

Whenever this formatter is used it will print the level, date and time,
module name, function name, line number and any string sent as parameter.
We can add other variables not present in `LogRecord`'s attributes by using
the `extra` attribute:

<h5 class="toggler" data-cls="fmts-dict-extra" data-default="true">
    Formatter with extra atributes using a dictionary
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="fmts-dict-extra">
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
</div>
<h5 class="toggler" data-cls="fmts-code-extra">
    Formatter with extra atributes using code
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="fmts-code-extra">
```python
import sys
import logging

# create Formatter
formatter = logging.Formatter(
    "[APP] %(levelname)s %(asctime)s %(module)s "
    "%(name)s.%(funcName)s:%(lineno)s: "
    "[%(session_key)s:%(user_id)s] %(message)s" # add extra data
)
```
</div>
<h5 class="toggler" data-cls="fmts-file-extra">
    Formatter with extra atributes using a dictionary
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="fmts-file-extra">
```python
[formatters]
key=detailed

[handlers]
key=console

[formatter_detailed]
format=[APP] %(levelname)s %(asctime)s %(module)s %(name)s.%(funcName)s:%(lineno)s: [%(session_key)s:%(user_id)s] %(message)s
datefmt=
class=logging.Formatter

[handler_console]
class=StreamHandler
level=DEBUG
formatter=detailed
args=(sys.stdout,)
```
</div>

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

> <i class="fab fa-python">&nbsp;</i> **Best Practice** <br/>
> Make sure to send every additional variable that the configured
> formatter references if using the `extra` parameter

### Filters

Filters are very interesting. They can be used both at the logger level
or at the handler level, they can be used to stop certain log events from
being logged and they can also be used to inject additional context into
a `LogRecord` instance which will be, eventually, logged.

The `Filter` class in Python's `logging` library filters `LogRecords` by
logger name. The filter will allow any `LogRecord` coming from the logger name
configured in the filter and any of its children.

For instance, if we have these loggers configured:

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

And we define the filter config like this:

<h5 class="toggler" data-cls="filters-dict" data-default="true">
    Filters definition using a dictionary
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="filters-dict">
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

We use the `"filter"` key in a dictionary configuration to define any filters.
Each key inside the `"filter"` object will become a filter we can later reference.
Every key and value inside the filter object we create will be sent as parameters
when intializing the filter.
</div>

<h5 class="toggler" data-cls="filters-code">
    Filters definition using code
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="filters-code">
```python
import logging

views_filter = logging.Filter(name="views")
console_handler.addFilter(views_filter)
console_logger.addHandler(console_handler)
```

Initializing a filter using code is straight forward.
We have to remember to use the handler's `addFilter` so a handler
can use the filter.
</div>

<h5 class="toggler" data-cls="filters-file">
    Filters definition using a file
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="filters-file">
```ini
[filters]
key=views

[handlers]
key=console

[filter_views]
name=views

[handler_console]
class=StreamHandler
level=DEBUG
filters=views
args=(sys.stdout,)
```

When using a file we have to first define the filter keys that we are going to reference.
To configure a filter we have to create a section with the name `filter_<name_of_filter>`.
In this case `filter_views`.
</div>

The previous configuration will **only** allow `LogRecord` coming from the
`app.views`, `app.views.users` and `app.views.products`
loggers.

When you set a filter to a specific logger the filter will **only** be used
when calling that logger directly and **not** when a descendant of said logger
is used. For example, if we had set the filter in the previous example to the
`app.view` logger instead of the `app` logger handler. The filter will not
reject any `LogRecord` coming from `app.models` loggers simply because when
using the logger `app.models`, or any of it's childrens, the filter will not be called.

Let's see how can we create custom
filters to prevent `LogRecords` to be processed based on more complicated conditions
and/or to add more data to a `LogRecord`.

**Since Python 3.2** you can use any callable that accepts a `record` parameter

```python
def custom_filter(record):
    """Filter out records that passes a specific key argument"""

    # We can access the log event's argument via record.args
    return record.args.get("instrumentation") == "console"
```

The way to configure these custom classes/callables using a dictionary or a file
is by using the special keyword `()`. Whenever Python's logging config sees
`()` it will create an instance of the class (dot notation has to be used).

> <i class="fas fa-bolt">&nbsp;</i> **Note:**
> When using a dictionary to configure logging you can use the `()`
> keyword to configure custom handlers or filters

Another interesting thing about filters is that they see virtually every `LogRecord`
that *might* be logged. This makes filters a great place to further customize `LogRecords`.
This is called "adding context".

##### Custom filter example

The following custom filter will apply a mask to every password passed to a `LogRecord`
**if** the `pwd` or `password` key is used.

```python
# module: app.logging.filters

def pwd_mask_filter(record)
    """A factory function that will return a filter callable to use."""

    def filter(record):
        # a Logger cord instance holds all it's arguments in record.args
        def mask_pwd(record):
            return '*' * 20

        if record.args.has_key("pwd"):
            record.args["pwd"] = mask_pwd()
        elif record.args.has_key("password"):
            record.args["pwd"] = mask_pwd()

    return filter
```

<h5 class="toggler" data-cls="filters-custom-dict" data-default="true">
    Custom filter configuration example using a dictionary
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="filters-custom-dict">

```python
LOGGING_CONFIG = {
    "version": 1,
    "formatters": {
        "detailed": {
            "format": "[APP] %(levelname)s %(asctime)s %(module)s "
                      "%(name)s.%(funcName)s:%(lineno)s: %(message)s"
        }
    },
    "filters": {
        "mask_pwd": {
            "()": "app.logging.filters.mask_pwd"
        }
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "detailed",
            "level": "INFO",
            "filters: ["mask_pwd"]
        }
    }
}
```

When using `()` in a dictionary configuration the referenced module will be imported
and instantiated. In this case the factory function `mask_pwd` will be called and
the actual function that handles filtering will be returned.
</div>

<h5 class="toggler" data-cls="filters-custom-code">
    Custom filter configuration example using code
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="filters-custom-code">
```python
import sys
import logging
from filters import mask_pwd

    
stream_handler = logging.StreamHandler(sys.stdout)
stream_handler.addFilter(mask_pwd())
```

Since we define `mask_pwd` as a factory function we have to instantiate it.
This way the handler is using the filter function returned by `mask_pwd`.
</div>

<h5 class="toggler" data-cls="filters-custom-file">
    Custom filter configuration example using a file
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="filters-custom-file">

> <i class="fas fa-bolt">&nbsp;</i> **Note:** <br />
> We cannot configure filters when using file configuration

</div>

### Handlers

Handlers are objects that implement how formatters and filters are used. if we remember the flow diagram we can see
that whenever we use a logger the handlers of all the parent loggers are going to be called recursivley.
This is where the entire picture comes together and we can take a look at a complete loggin configuration
using everything else we've talked about.

Python offers a list of very useful [handlers][logging-handlers]. Handler classes have a very simple API and in most
cases we will only use these classes to add a formatter, zero or more filters and setting the logging level.

> <i class="fas fa-bolt">&nbsp;</i> **Note:** <br />
> Only **one** formatter can be set to a handler.

For instance, the following configuration makes sure that every log is printed to the standard output, uses a filter
to select a different handler depending if the application is running in debug mode or not and it uses a different
format for each different environment (based on the debug flag).

#### Full logging configuration example

<h5 class="toggler" data-cls="full-config-dict" data-default="true">
    Configuration using a dict
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="full-config-dict">
```python
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "long": {
            "format": "[APP] {levelname} {asctime} {module} "
                      "{name}.{funcName}:{lineno:d}: {message}",
            "style": "{"
        },
        "short": {
            "format": "[APP] {levelname} [{asctime}] {message}",
            "style": "{"
        }
    },
    "filters": {
        "debug_true": {
            "()": "filters.require_debug_true_filter"
        },
        "debug_false": {
            "()": "filters.require_debug_false_filter"
        }
    },
    "handlers": {
        "console": {
            "level": "INFO",
            "class": "logging.StreamHandler",
            "formatter": "short",
            "filters": ["debug_false"]
        },
        "console_debug": {
            "level": "DEBUG",
            "class": "logging.StreamHandler",
            "formatter": "long",
            "filters": ["debug_true"]
        }
    },
    "loggers": {
        "external_library": {
            "handlers": ["console"],
            "level": "INFO"
        },
        "app": {
            "handlers": ["console", "console_debug"],
            "level": "DEBUG"
        }
    }
}
```
</div>

<h5 class="toggler" data-cls="full-config-code">
    Configuration using code
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="full-config-code">
```python
import logging
import app.settings

def require_debug_true_filter():
    """Only process records when DEBUG is True"""
    return app.settings.DEBUG

def require_debug_false_filter():
    """Only process records when DEBUG is False"""
    return !app.settings.DEBUG

# in app's entry point

# create logger
app_logger = logging.getLogger("app")
app_logger.setLevel(logging.DEBUG)

external_library_logger = logging.getLogger("external_library")
external_library_logger.setLevel(logging.INFO)

# long formatter
long_fmt = logging.Formatter(
    "[APP] {levelname} {asctime} {module} {name}.{funcName}:{lineno:d}: {message}",
    style="{"
)

# short formatter
short_fmt = logging.Formatter(
    "[APP] {levelname} [{asctime}] {message}",
    style="{"
)

# console handler config
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
console_handler.setFormatter(short_fmt)
console_handler.addFilter(require_debug_false_filter)

# console debug handler config
console_debug_handler = logging.StreamHandler()
console_debug_handler.setLevel(logging.DEBUG)
console_debug_handler.setFormatter(long_fmt)
console_debug_handler.addFilter(require_debug_true_filter)

app_logger.addHandler(console_handler)
app_logger.addHandler(console_debug_handler)
external_library_logger.addHandler(console_handler)
```
</div>

<h5 class="toggler" data-cls="full-config-file">
    Configuration using a file
    <i class="icon-show fas fa-angle-down" />
    <i class="icon-hide fas fa-angle-up"/>
</h5>
<div class="full-config-file">
```ini
[loggers]
keys=root,external_library,app

[handlers]
keys=console,console_debug

[formatters]
keys=long,short

[formatter_long]
format=[APP] {levelname} {asctime} {module} {name}.{funcName}:{lineno:d}: {message}
style={
datefmt=
class=logging.Formatter

[formatter_short]
format=[APP] {levelname} [{asctime}] {message}
style={
datefmt=
class=logging.Formatter

[handler_console]
class=StreamHandler
level=INFO
formatter=short
args=(sys.stdout,)

[handler_console_debug]
class=StreamHandler
level=DEBUG
formatter=long
args=(sys.stdout,)

[logger_root]
level=NOTSET
handlers=console

[logger_external_library]
level=INFO
handlers=console
propagate=1
qualname=external_library

[logger_app]
level=DEBUG
handlers=console,console_debug
qualname=app
```
</div>

When using a dictionary configuration `disable_existing_loggers` is set to `True` by default.
What this does is that it will grab all the loggers created before the configuration is applied
and disable them so they cannot process any log events. This is specially important when
creating loggers at the module level.

Say we have a `app.models.client` module in which we create a logger like this:

```python
# app.models.client

import logging

LOG = logging.getLogger(__name__)

class Client:
    # ...
```

And then in our application's entry point we import our models and configure our logging:

```python
# app.__main__

import logging
from app.settings.logging import LOGGING_CONFIG # A dictionary
from app.models import Client

logging.config.dictConfig(LOGGING_CONFIG)
```

In this case the logger created in `app.models.client` will not work unless `disable_existing_loggers`.
Because when we import the `Client` class from `app.models` we are initializing the logger used
in `app.models.client`. Then, after the logger is already initialized we apply our configuration, making
any existing loggers disabled.

When definig a handler using a dictionary, any key that is not `class`,
`level`, `formatter` or `filters` will be passed as a parameter to
the handler's class specified for instantiation.

Filters cannot be used when using a file to configure logging. One more reason
why is better to use a dictionary for configuration.


## Things to lookout for when configuring your loggers

- Filters can be set both to Loggers and Handlers. If a filter is set at the logger level
  it will only be used when that specific logger is used and not when any of its descendants are used.
- File config is still support purely for backwards compatibility. Avoid using file config.
- `()` can be used in config dictionaries to specify a custom class/callable to use as
  formatter, filter or handler. It's assumed a factory is referenced when using `()` to allow for complete
  initialization control.
- Go over the [list of cases](#every-log-event-created-will-be-processed-except-in-the-following-cases) when
  a log event is not processed if you don't see what you expect in your logs.
- Make sure to set `disable_existing_loggers` to `False` when using dict config and creating loggers
  at the module level.

## Recommendations for better logging

- Take some time to plan how your logs should look like and where are they going to be stored.
- Make sure your logs are easily parsable both visually and programmatically, like using `grep`.
- Most of the time you don't need to set a filter at the logger level.
- Filters can be used to add extra context to log events. Make sure any custom filters are fast.
  In case your filters do external calls consider using a [queue handler][zero-mq-handler]
- Log more than errors. Make sure whenever you see an error in the logs you can trace back
  the state of the data in the logs as well.
- If you are developing a library, always set a [`NullHandler` handler][null-handler] and let the user
  define the logging configuration.
- Use the handlers already offered by Python's logging library  unless is a very special case.
  Most of the time you can hand off the logs and then process them with a more specialized tool.
  For example, send logs to `syslog` using [`syslogHandler` handler][sys-log-handler]
  and then use `rsyslog` to maintain your logs.
- Create a new logger using the module's name to avoid collisions, `logging.getLogger(__name__)`


> <i class="fas fa-bolt">&nbsp;</i> **Note:** <br />
> If you want to use the test the configuration above or just play around with different configs,
> checkout the [complementary repo to this article](https://github.com/rmcomplexity/intro-to-python-logging)

[python-howto-logging]: https://docs.python.org/3/howto/logging.html
[hitchhikers-logging]: https://docs.python-guide.org/writing/logging/
[docker-logging-drivers]: https://docs.docker.com/config/containers/logging/configure/
[tacc]: https://tacc.utexas.edu
[splunk]: https://www.splunk.com/
[logging-levels]: https://docs.python.org/3/library/logging.html#logging-levels
[logrecord-attrs]: https://docs.python.org/3/library/logging.html#logrecord-attributes
[basic-config]: https://docs.python.org/3/library/logging.html#logging.basicConfig
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
[zero-mq-handler]: https://docs.python.org/3/howto/logging-cookbook.html#subclassing-queuehandler-a-zeromq-example
[null-handler]: https://docs.python.org/3/library/logging.handlers.html#logging.NullHandler
[sys-log-handler]: https://docs.python.org/3/library/logging.handlers.html
