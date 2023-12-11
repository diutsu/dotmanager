# DotManager

DotManager is a simple script for managing your dotfiles, allowing you to install, update, add, check status, or view differences with ease.

## Instalation

Download the `./dotmanager.sh` to your local system

## Usage

```bash
./dotmanager.sh [-iua:hsD:] [file]
```

### Expected dot files structure
This script will install your dotfiles from your `$DOTFILES` folder to your local system, keeping the relative folder structure. So if you have a file under `$DOTFILES/.somerc` it will match `$HOME/.somerc`, similarly `$DOTFILES/foo/bar/.somerc` it will match `$HOME/foo/bar/.somerc`

Note: this script will only copy files, it will ignore any empty directories insides the manages files.

## Using it with git

This script works great if you already have your dotfiles inside a git repository. You can even have this script as part of your own dotfiles repo.  
This way you can your repo and run this script to install your dotfiles in your local machine.


```
repository-root/
├── dotmanager.sh
├── .git/
└── files/
    ├── (your managed files and folders)```
    ├── foo
    │   ├── bar
    │   │   └── .somerc
    └── .zshrc
```

In case you ever modify your dotfiles you can run this script in update mode to update your versioned files and then push your new changes to your remote repository.

### Dotfiles location Configuration

By default, the script will look for files to manage under a local ./files directory. You can customize this by setting the DOTFILES environment variable. For example:

```bash
export DOTFILES=/path/to/dotfiles
./dotmmanager.sh -s
```

## Options:

    -i: Install mode
    -u: Update mode
    -a <file>: Add mode. Add a new file to the 'files/' folder.
    -h: Print this help message.
    -s: Status mode. Print the status between the source and destination directories.
    -D <file>: Diff mode. Print the difference with the specified file.

## Modes
### Install Mode (-i)

This mode installs dotfiles to the home directory. If a file already exists, it checks for differences and updates accordingly.

### Update Mode (-u)

This mode updates dotfiles in the source directory (./files) with the files in the home directory. It prints whether files were updated or created.

### Add Mode (-a <file>)

This mode adds a new file to the 'files/' folder. It checks if the file already exists and updates it if necessary.

### Status Mode (-s)

This mode prints the status between the source (./files) and destination (home) directories. It indicates whether files are up to date, need updates, or are missing locally.

### Diff Mode (-D <file>)

This mode prints the difference between the specified file and the corresponding managed file. It ensures the file is one of the managed files.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Liability Disclaimer

This software is provided "as is," without warranty of any kind, express or implied. The authors or contributors of this software shall not be held liable for any claims, damages, or other liabilities arising from the use of this software.

Use this software at your own risk. While efforts have been made to ensure its reliability, it is ultimately the responsibility of the user to verify its suitability for their specific use case.
