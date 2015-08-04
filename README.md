## Summary

This project contains the source code for sensoricollective.com.

### Stack
- rvm
- ruby 2.1
- rails 3.2
- bundler
- mysql 5.5
- redis
- sidekiq

#### Development
- os x
- homebrew

#### Production
- ubuntu 12.10
- upstart
- unicorn / nginx

## Running Tests

```
bundle exec rspec
bundle exec rake jasmine:ci
```

## Configuration
- Install stack dependencies as listed above
- `bundle install`
- Copy `config/database.yml.example` to `config/database.yml` and edit as necessary.
- Copy `config/application.yml.example` to `config/application.yml`.

This should be enough for rspec and jasmine test suites to pass.

### Soundcloud
- Sensori uses the Soundcloud API for user authentication and related services.
- For a fully functioning dev environment, you'll need a [Soundcloud developer account](https://developers.soundcloud.com/) and your own dev application.
- When your Soundcloud application has been created, edit its settings from [Your Applications](http://soundcloud.com/you/apps).
- Change the "Redirect URI for Authentication" setting to `http://localhost:3000/members/soundcloud_connect`
- Edit `config/application.yml`:

```
development:
  soundcloud:
    client_id: YOUR_SOUNDCLOUD_ID
    secret: YOUR_SOUNDCLOUD_SECRET
  ...
```

### AWS
- Sensori uses S3 for storing uploaded files and SES for email delivery.
- For a fully functioning dev environment, you'll need an [AWS account]().
- Follow [these docs](http://docs.aws.amazon.com/general/latest/gr/getting-aws-sec-creds.html) for getting your `access_key_id` and `secret_access_key`.
- Create an S3 bucket and [edit permissions](http://docs.aws.amazon.com/AmazonS3/latest/UG/EditingBucketPermissions.html) so your access credentials have full permissions (and optionally enable public read access).
- TODO: SES setup
- Edit `config/application.yml`:

```
development:
  aws:
    access_key_id: YOUR_ACCESS_KEY_ID
    secret_access_key: YOUR_SECRET_KEY
    s3_bucket: your-bucket-name
  ...
```
