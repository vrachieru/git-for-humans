# Server-Side Hooks

These scripts run before and after pushes to the server. The pre hooks can exit non-zero at any time to reject the push as well as print an error message back to the client; you can set up a push policy that’s as complex as you wish.

#### pre-receive
The first script to run when handling a push from a client is pre-receive. It takes a list of references that are being pushed from stdin; if it exits non-zero, none of them are accepted.

#### update
The update script is very similar to the pre-receive script, except that it’s run once for each branch the pusher is trying to update. If the pusher is trying to push to multiple branches, pre-receive runs only once, whereas update runs once per branch they’re pushing to. Instead of reading from stdin, this script takes three arguments: the name of the reference (branch), the SHA-1 that reference pointed to before the push, and the SHA-1 the user is trying to push. If the update script exits non-zero, only that reference is rejected; other references can still be updated.

#### post-receive
The post-receive hook runs after the entire process is completed and can be used to update other services or notify users. It takes the same stdin data as the pre-receive hook. Examples include emailing a list, notifying a continuous integration server, or updating a ticket-tracking system – you can even parse the commit messages to see if any tickets need to be opened, modified, or closed. This script can’t stop the push process, but the client doesn’t disconnect until it has completed, so be careful if you try to do anything that may take a long time.


# Installation

`export repo_path=/var/opt/gitlab/git-data/repositories/<group>/<repository>.git`

1. Create a custom_hooks directory in your repo  
   `mkdir $repo_path/custom_hooks`
2. Copy the hooks into the newly created folder  
   `cp <hook> $repo_path/custom_hooks`
3. Rename the hooks leaving just their extensions (merge multiple hooks if necessary)  
   `mv <hook-name>.<hook-type> <hook-type>`
4. Give git ownership over the folder and files  
   `chown -R git:git $repo_path/custom_hooks`
5. Give execution rights to the hooks  
   `chmod -R 755 $repo_path/custom_hooks`