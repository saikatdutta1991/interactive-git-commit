# interactive-git-commit
Git hook builder that helps developers to write proper commit messages with an interactive Question-Answer input style.

#### Dependencies

------------

- **jq** : jq is a lightweight and flexible command-line JSON processor.

#### Supported platforms

------------

- OS X ( 64 bit )
- Linux ( 64 bit )

#### Get Started

------------

##### Step 1:

------------

Download or clone the project into your local machine. 
```shell
git clone https://github.com/saikatdutta1991/interactive-git-commit.git
```

##### Step 2:

------------

Edit `gitmessage.config.json` file as per your commit message interactive template.

Sample `gitmessage.config.json` 
```javascript
{
	// Default visible commit message segments.
	// Each input form this segment will be concatinated automatically with a colon(:) seperator. 
	// Ex : Style:Gitignore file added 
  "commitFirstLine": [
    {
      "q": "Enter commit type:", // Question that will be asked user to input 
      "aHeader": "Type", // Section header
      "type": "option", // Interactive option input type
      "values": ["Feat", "Fix", "Docs", "Style", "Refactor", "Test", "Chore"], // Possible option values to choose from
      "isOptional": false // is mandatory user input
    },
    {
      "q": "Enter commit subject:",
      "aHeader": "Subject",
      "type": "text",
      "isOptional": false
    }
  ],
  //  Extended commit message.
  "commitQuestions": [
    {
      "q": "Describe about existing problem:",
      "aHeader": "Problem",
      "type": "text",
      "isOptional": false,
      "addAnswerNextLine": true
    },
    {
      "q": "Brief your solution for the problem:",
      "aHeader": "Solution",
      "type": "text",
      "isOptional": false,
      "addAnswerNextLine": true
    },
    {
      "q": "Enter any special note:",
      "aHeader": "Note",
      "type": "text",
      "isOptional": true,
      "addAnswerNextLine": true
    }
  ]
}

```

Sample Git commit message based on above configuration.
```yaml
commit 90bd3065cc574266301bed1e6ee7ecba0ea960f2 (HEAD -> master)
Author: Saikat Dutta <saikatdutta@Saikats-MacBook-Air.local>
Date:   Sun May 10 20:03:57 2020 +0530

    Fix:Your subject
    
    Problem:
    Your existing problem
    
    Solution:
    Solution for the above problem
    
    Note:
    ---
```

##### Step 3:

------------

Give excutable permission for these files
- `commitHookBuilder.sh`
- `jq-linux64`
- `jq-osx-amd64`

Example:
```shell
sudo chmod +x commitHookBuilder.sh
```

##### Step 4:

------------

Go to directory `interactive-git-comiit` and run below command.
```bash
./commitHookBuilder.sh
```
This command will generate following output:

```
Commit builder started
prepare-commit-msg file generated in the directory. Copy into your project .git/hooks/ directory. Give executable permiss
ion. Command: sudo chmod +x .git/hooks/prepare-commit-msg
Commit builder executed successfully
```
##### Step 5:

------------

`prepare-commit-msg` file will be genrated if previous command executes successfully.
Copy the generated `prepare-commit-msg` file into your desired project `./git/hooks/` directory. Make sure to give executable permission for the `prepare-commit-msg` file.
