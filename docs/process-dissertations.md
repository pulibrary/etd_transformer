# How to process dissertations

## 1. Get the dissertations
1. ProQuest will transfer these to our SFTP server several times per year. Lynn Durgin will be in touch when there are new dissertations needing ingest.
1. Connect to `proquest@proquestdrop.pulcloud.io` and the dissertations will be in `/pultheses/proquest`. Note that you will need your public ssh key added to the server in order to connect. 
1. Once you have downloaded the current batch for processing, move them on the SFTP server into the `processed` folder, following the date-based directory structure you'll find there. This will make it easier to audit in the future which dissertations were transferred on which days. 

## 2. Run the process
1. Download the `etd_transformer` code and follow the installation instructions in the README. 
2. Invoke the script like this:

```
% thor help etd_transformer:cli:process_dissertations
Usage:
  thor etd_transformer:cli:process_dissertations

Options:
  [--input=INPUT]                              # Full path to input files
  [--output=OUTPUT]                            # Full path to output

% thor etd_transformer:cli:process_dissertations --input /full/path/to/downloaded/dissertations --output /full/path/to/output/folder/YYYYMMDD
```

## 3. Upload and Import to DSpace
Zip up the processed dissertations and upload them to the dataspace-dev server:

```

% cd /full/path/to/output/folder
% tar czvf YYYYMMDD.tar.gz YYYYMMDD
% scp YYYYMMDD.tar.gz dspace@dataspace_dev:/home/dspace/dspace_imports/dissertations/2021/
```

SSH to the Dataspace box, ensure the file is in the right place, and unzip it.

```
% ssh dataspace_dev
pulsys@gcp-dataspace-dev1:~ $ sudo su dspace
dspace@gcp-dataspace-dev1:~ $ cd ~/dspace_imports/dissertations/2021
dspace@gcp-dataspace-dev1:~/dspace_imports/dissertations/2021 $ tar zxvf YYYYMMDD.tar.gz
```

Import the files into Dataspace:

```
/dspace/bin/dspace import -add --eperson bess.sadler@princeton.edu --source $HOME/dspace_imports/dissertations/2021/YYYYMMDD --mapfile $HOME/dspace_imports/dissertations/2021/YYYYMMDD.mapfile --workflow
```

4. If everything looks good on dataspace-dev, follow the same process for production. Keep Lynn Durgin informed on progress.

### Troubleshooting

When you import on dataspace-dev you might run into errors about it not being able to mint handles. You can fix the problem like this:
* On dataspace-dev, edit the file `/dspace/config/dspace.cfg`
* Edit the section on handles so it looks like this: This will enable minting of handles in TEST mode.

```
  # We have hijacked the Handle Prefix to indicate our ARK naming assigning authority
  #  number (NAAN) instead.
  handle.prefix = 99999

  # This plus the ARK identifier is stored as the persistent URI of the Item
  handle.canonical.prefix = http://arks.princeton.edu/ark:/

  # These are configuration parameters for the EZID ARK minting service
  ark.ezid_server = https://ezid.cdlib.org
  ark.ezid_username = apitest
  ark.ezid_password = apitest
  ark.shoulder = fk4
```

* Run `dsrestart` to restart DSpace, then try the import again.
