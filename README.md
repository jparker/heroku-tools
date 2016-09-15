# heroku-tools

A collection of scripts for working with [Heroku](https://heroku.com).

## hrun

The `hrun` script is a wrapper for running `heroku run` from cron. It directs
STDOUT and STDERR to log files. If the command completes successfully (with a
non-zero exit value), no output is produced. If the command exits with a
non-zero exit value, the contents of the logs are printed which cron will send
via email.

The following command:

```bash
hrun -a still-beyond-12345 -p $HOME/log/command rake foo
```

will be expanded to the following:

```bash
heroku run rake foo -x NEW_RELIC_AGENT_ENBALED="false" 2>$HOME/log/command.err >$HOME/log/command.log
```

If the application is hooked up with [New Relic](http://newrelic.com), the
agent will be **disabled** by default. You can enable the agent by passing the
<kbd>-n</kbd> option to `hrun`.

## ph

The `ph` script runs arbitrary `heroku` commands against multiple applications
in parallel. By default it runs against all applications returned by
`heroku apps`, but you can use the <kbd>-r</kbd> option to only run against
applications with name matching a given regular expression.

```bash
ph -r production run rails runner 'ruby --version'
```

Pass the <kbd>-j</kbd> option to specify the number of jobs to run in parallel.
(By default, five jobs will be run.)

**WARNING:** Recent enhancements to the Heroku CLI have broken this script. It
works, but the terminal is in a bad state when the command completes. You can
restore things by running `stty echo` afterwards. I haven't had time to figure
out how to work around this.

## LICENSE

These scripts are available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
