@echo off
C:
cd C:\deploy
AzCopy C:\deploy\autoupdate https://azcdn.blob.core.windows.net/autoupdate /destkey:q2IfR7j2hlHjnGLkcQlL0IlY0dKfiDW9ut+PRmAaFnOGnLX6jXcQpBT66RsmgwWX3rO9fx6BDeny0on8iUC96Q== /S /XO /Y
AzCopy C:\deploy\install https://azcdn.blob.core.windows.net/install /destkey:q2IfR7j2hlHjnGLkcQlL0IlY0dKfiDW9ut+PRmAaFnOGnLX6jXcQpBT66RsmgwWX3rO9fx6BDeny0on8iUC96Q== /S /XO /Y
AzCopy C:\deploy\config https://azcdn.blob.core.windows.net/config /destkey:q2IfR7j2hlHjnGLkcQlL0IlY0dKfiDW9ut+PRmAaFnOGnLX6jXcQpBT66RsmgwWX3rO9fx6BDeny0on8iUC96Q== /S /XO /Y
