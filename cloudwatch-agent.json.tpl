
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/secure",
            "log_group_name": "bastion-secure-logs",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name": "bastion-system-logs",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}

