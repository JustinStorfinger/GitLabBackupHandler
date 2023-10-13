# GitLab Backup Handler

## Usage

```bash
bash run {backup|restore}
```

|Command|Description|
|--|--|
|backup|Run gitlab backup and create backup of configuration files|
|restore|Restore gitlab backup as well configuration backup (You need to have the same version as the created backup)|
|-h or --help or help or usage|Displays the usage help|

## Notes

- You need to have the same GitLab version installed as when the backup was created. Also applies to the configuration backup
- Backups older than 7 days will only be deleted when configured properly in the GitLab configuration file