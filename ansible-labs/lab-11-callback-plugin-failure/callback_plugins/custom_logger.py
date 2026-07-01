# Custom callback plugin for external JSON logging
# This plugin sends task execution events to an external logging system

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = '''
    name: custom_logger
    type: notification
    short_description: Send task events to external logging system
    description:
        - This callback plugin sends JSON-formatted task execution events
          to an external logging system via HTTP POST
    requirements:
        - whitelisting in configuration
        - requests library (pip install requests)
'''

import json
import datetime
# BUG 1: Import error - 'requests_toolbelt' is not installed by default
# The actual needed module is just 'requests', but this imports a non-existent submodule
from requests_toolbelt.multipart import encoder as multipart_encoder
import requests

from ansible.plugins.callback import CallbackBase

# BUG 2: CALLBACK_TYPE should be 'notification' for non-stdout plugins
# Setting it to 'stdout' causes conflicts with the default stdout callback
CALLBACK_TYPE = 'stdout'
CALLBACK_NAME = 'custom_logger'

# BUG 3: This should be CALLBACK_NEEDS_WHITELIST for older versions,
# but more importantly the ansible.cfg uses deprecated 'callback_whitelist'
CALLBACK_NEEDS_ENABLED = True


class CallbackModule(CallbackBase):
    """
    Custom callback plugin that logs all task events to external system.
    """

    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'  # BUG 2 repeated: should be 'notification'
    CALLBACK_NAME = 'custom_logger'

    def __init__(self, *args, **kwargs):
        super(CallbackModule, self).__init__(*args, **kwargs)
        self.log_endpoint = "http://logging-system.internal:9200/ansible-events/_doc"
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'X-Source': 'ansible-callback'
        })
        self._task_start_time = None

    def _send_event(self, event_type, data):
        """Send event to logging system"""
        payload = {
            'timestamp': datetime.datetime.utcnow().isoformat(),
            'event_type': event_type,
            'data': data,
            'source': 'ansible-controller'
        }
        try:
            # Uses multipart_encoder unnecessarily (and it's not installed)
            encoded = multipart_encoder.MultipartEncoder(
                fields={'event': json.dumps(payload)}
            )
            self.session.post(self.log_endpoint, data=encoded,
                           headers={'Content-Type': encoded.content_type})
        except Exception:
            # Silent failure - no logging of the error itself
            pass

    def v2_playbook_on_start(self, playbook):
        self._send_event('playbook_start', {
            'playbook': playbook._file_name
        })

    # BUG 4: Wrong method signature for v2_runner_on_ok
    # Correct signature is: v2_runner_on_ok(self, result)
    # This has extra parameters that don't match the callback API
    def v2_runner_on_ok(self, result, ignore_errors=False, **kwargs):
        """Called when a task succeeds"""
        host = result._host.get_name()
        task_name = result._task.get_name()
        task_result = result._result

        self._send_event('task_ok', {
            'host': host,
            'task': task_name,
            'result': task_result,
            'ignore_errors': ignore_errors,
            'duration': self._get_duration()
        })

    # BUG 4 continued: Wrong signature for v2_runner_on_failed too
    # Correct: v2_runner_on_failed(self, result, ignore_errors=False)
    def v2_runner_on_failed(self, result, exception_text=None, **kwargs):
        """Called when a task fails"""
        host = result._host.get_name()
        self._send_event('task_failed', {
            'host': host,
            'task': result._task.get_name(),
            'msg': result._result.get('msg', 'unknown error'),
            'exception': exception_text
        })

    def v2_runner_on_skipped(self, result):
        self._send_event('task_skipped', {
            'host': result._host.get_name(),
            'task': result._task.get_name()
        })

    def v2_playbook_on_stats(self, stats):
        """Called at the end of the playbook"""
        hosts = sorted(stats.processed.keys())
        summary = {}
        for h in hosts:
            s = stats.summarize(h)
            summary[h] = s

        self._send_event('playbook_complete', {
            'summary': summary
        })

    def _get_duration(self):
        if self._task_start_time:
            return (datetime.datetime.utcnow() - self._task_start_time).total_seconds()
        return 0
