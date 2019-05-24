# general feature branch workflow
git checkout master
git checkout -b feature_branch # work happens on feature branch
# CICD tooling automates testing on each commit to feature_branch
# mandatory pull request approved before merged with master(QA) branch
git checkout master # protected branch with required checks and limited write access
git merge feature_branch # automated testing through CICD based on merge
# merge into prod, only one deployment at a time
git checkout prod # protected branch with required checks and limited write access
git merge master # automated testing and rollback through CICD based on merge
git branch -d feature_branch # delete branch

# hot fix workflow
git checkout prod
# or checkout the last known good branch commit
git log -n1 #lists previous commit
git checkout <sha1> #checkout specific branch with commit tag
git checkout -b hotfix_branch # work happens on hotfix branch
#merge into prod
git checkout prod
git merge hotfix_branch
# merge into master(QA)
git checkout master
git merge hotfix_branch
git branch -D hotfix_branch # delete branch
# depending on hotfix, further testing to be developed in a feature branch

