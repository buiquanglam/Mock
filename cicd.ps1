function Apply {
  set-content -path './branches/dev/hosts' -value $null
  write-output 'Creating branch dev ansible hosts file...'

  set-content -path './branches/prod/hosts' -value $null
  write-output 'Creating branch prod ansible hosts file...'

  set-content -path './branches/master/hosts' -value $null
  write-output 'Creating branch master ansible hosts file...'

  set-content -path './modules/module-github/variables.tf' -value $null
  write-output 'Creating github-webhook file...'

  set-content -path './prometheus.yml' -value $null
  write-output 'Creating prometheus.yml file...'

  set-content -path './Jenkinsfile' -value $null
  # get-content -path './Jenkinsfile.tpl' -raw | add-content -path .\Jenkinsfile
  write-output 'Creating Jenkinsfile.tpl file...'

  if (test-path -path '~/.ssh/khoamd-terraform.pem') {
    write-output 'keypair.pem file has been created'
  } else {
    new-item -path ~/.ssh/khoamd-terraform.pem -itemtype "file" -force
    write-output 'Creating keypair.pem file...'
  }

  if (test-path -path '~/.ssh/khoamd-terraform.pub') {
    write-output 'keypair.pub file has been created'
  } else {
    new-item -path ~/.ssh/khoamd-terraform.pub -itemtype "file" -force
    write-output 'Creating keypair.pub file...'
  }

  terraform init -upgrade
  terraform plan --out tfplan
  terraform apply tfplan
  write-output "AWS Apply terraform done"
  write-warning 'You have run the action Apply'
}

function Refresh {
  terraform plan -refresh-only
  write-output "AWS Refresh terraform done"
  write-warning 'You have run the action Refresh'
}

function Destroy {
  terraform destroy --auto-approve

  if (test-path -path '~/.ssh/khoamd-terraform.pem') {
    write-output 'keypair.pem file has been created'
  } else {
    new-item -path ~/.ssh/khoamd-terraform.pem -itemtype "file" -force
    write-output 'Creating keypair.pem file...'
  }

  if (test-path -path '~/.ssh/khoamd-terraform.pub') {
    write-output 'keypair.pub file has been created'
  } else {
    new-item -path ~/.ssh/khoamd-terraform.pub -itemtype "file" -force
    write-output 'Creating keypair.pub file...'
  }
  
  write-output "AWS Destroy terraform done"
  write-warning 'You have run the action Destroy'
}

function VersionUp {
  param (
    $old_version = (get-content ./version),
    $split_version = $old_version.Split(' '),
    $last_word = $split_version[$split_version.Length - 1],
    $last_character = ($last_word.Length - 1),
    $first_dot = $last_word.IndexOf('.'),
    $last_dot = $last_word.LastIndexOf('.')
  )

  # Determine version components
  if ($first_dot % 2 -eq 1) {$first_number = $last_word.substring(0, 1)}
  if ($first_dot % 2 -eq 0) {$first_number = $last_word.substring(0, 2)}
  if ($first_dot -ge 3) {$first_number = 99 -as [byte]}
  $first_number = $first_number -as [byte]

  if ($last_dot - $first_dot -eq 2) {
    $middle_number = $last_word.substring($first_dot + 1, 1)
  }
  if ($last_dot - $first_dot -eq 3) {
    $middle_number = $last_word.substring($first_dot + 1, 2)
  }
  if ($last_dot - $first_dot -ge 4) {$middle_number = 99 -as [byte]}
  $middle_number = $middle_number -as [byte]

  if ($last_character - $last_dot -eq 1) {
    $last_number = $last_word.substring($last_dot + 1, 1)
  }
  if ($last_character - $last_dot -eq 2) {
    $last_number = $last_word.substring($last_dot + 1, 2)
  }
  if ($last_character - $last_dot -ge 3) {$last_number = 99 -as [byte]}
  $last_number = $last_number -as [byte]

  # Up to new version number
  [bool]$version_status = 0
  if (($first_number -eq 99) -and ($middle_number -eq 99) -and ($last_number -eq 99)) {
    $first_number = 0
    $middle_number = 0
    $last_number = 0
    [bool]$version_status = 1
  }
  if (($first_number -lt 99) -and ($middle_number -eq 99) -and ($last_number -eq 99) -and $version_status -eq 0) {
    $first_number += 1
    $middle_number = 0
    $last_number = 0
    [bool]$version_status = 1
  }
  if (($first_number -eq 99) -and ($middle_number -lt 99) -and ($last_number -eq 99) -and $version_status -eq 0) {
    $middle_number += 1
    $last_number = 0
    [bool]$version_status = 1
  }
  if (($first_number -eq 99) -and ($middle_number -eq 99) -and ($last_number -lt 99) -and $version_status -eq 0) {
    $last_number += 1
    [bool]$version_status = 1
  }
  if (($first_number -lt 99) -and ($middle_number -lt 99) -and ($last_number -eq 99) -and $version_status -eq 0) {
    $last_number = 0
    $middle_number += 1
    [bool]$version_status = 1
  }
  if (($first_number -lt 99) -and ($middle_number -eq 99) -and ($last_number -lt 99) -and $version_status -eq 0) {
    $last_number += 1
    [bool]$version_status = 1
  }
  if (($first_number -eq 99) -and ($middle_number -lt 99) -and ($last_number -lt 99) -and $version_status -eq 0) {
    $last_number += 1
    [bool]$version_status = 1
  }
  if (($first_number -lt 99) -and ($middle_number -lt 99) -and ($last_number -lt 99) -and $version_status -eq 0) {
    $last_number += 1
  }

  # Set new version variable
  set-content -path './current-gitlog' -value $null
  git log -- .\cicd.ps1 > current-gitlog
  $currentGitLog = get-content ./current-gitlog
  if ($null -eq $currentGitLog) {
    [String]$new_version = "0.0.1"
  }
  else {
    $new_version = [System.String]::Concat($first_number, ".", $middle_number, ".", $last_number)
  }

  # Write new version to version file
  $new_version_file_content = [System.String]::Concat('Demo version ', $new_version)
  set-content -path './version' -value $new_version_file_content
  write-output 'Updating new version file...'
  write-warning 'You have run the action VersionUp'
}

function GitApply {
  git init
  set-location .\modules\module-github\
  terraform init -upgrade
  terraform plan --out tfplan
  terraform apply tfplan

#   set-content -path '~/.github/github-link.json' -value $null
#   $origin = terraform output -raw mnikhoa_demo_1st_pipeline_https_link
#   add-content -path ~/.github/github-link.json -value @'
#   {
#     "origin" : "$origin"
#   }
# '@
#   $json = (get-content "~/.github/github-link.json" -raw) | convertfrom-json
#   $origin = $json.psobject.properties.where({$_.name -eq "origin"}).value
#   git remote add origin $origin

  $remote_branch = git remote
  if ($null -eq $remote_branch) {
    $origin = terraform output -raw mnikhoa_demo_1st_pipeline_https_link
    git remote add origin $origin
  } else {
    git remote remove $remote_branch
    $origin = terraform output -raw mnikhoa_demo_1st_pipeline_https_link
    git remote add origin $origin
  }

  git branch --show-current > ../../default-gitbranch
  set-location ../../
  write-output "Git apply done"

  set-content -path './.gitignore' -value $null
  get-content -path .\branches\master\.gitignore-master.tpl -raw | add-content -path .\.gitignore
  write-output 'Creating .gitignore file...'

  write-warning 'You have run the action GitApply'
}

function GitMaster {
  if (test-path -path './.git') {
    write-warning 'Changing to Master branch...'
  } else {git init}
  $currentGitLog = git log -- .\cicd.ps1
  if ($null -eq $currentGitLog) {
    write-warning 'You are in Master branch...'
  } else {
    $defaultGitBranch = get-content ./default-gitbranch
    git checkout $defaultGitBranch
  }

  set-content -path './.gitignore' -value $null
  get-content -path .\branches\master\.gitignore-master.tpl -raw | add-content -path .\.gitignore
  write-output 'Creating .gitignore file...'

  write-warning 'You have run the action GitMaster'
}

function GitProd {
  if (test-path -path './.git') {
    write-warning 'Changing to Prod branch...'
  } else {git init}
  $dev = 'prod'
  $gitBranchList = git branch --list
  if ($null -eq $gitBranchList) {
    invoke-command ${function:VersionUp}
    invoke-command ${function:GitPush}
    git branch prod
    git checkout prod
  }
  if ($dev -notin $gitBranchList) {
    git branch prod
    git checkout prod
  }

  set-content -path './.gitignore' -value $null
  get-content -path .\branches\prod\.gitignore-prod.tpl -raw | add-content -path .\.gitignore
  write-output 'Creating .gitignore file...'

  write-warning 'You have run the action GitProd'
}

function GitDev {
  if (test-path -path './.git') {
    write-warning 'Changing to Dev branch...'
  } else {git init}
  $dev = 'dev'
  $gitBranchList = git branch --list
  if ($null -eq $gitBranchList) {
    invoke-command ${function:VersionUp}
    invoke-command ${function:GitPush}
    git branch dev
    git checkout dev
  }
  if ($dev -notin $gitBranchList) {
    git branch dev
    git checkout dev
  }

  set-content -path './.gitignore' -value $null
  get-content -path .\branches\dev\.gitignore-dev.tpl -raw | add-content -path .\.gitignore
  write-output 'Creating .gitignore file...'

  write-warning 'You have run the action GitDev'
}

function GitPush {
  # Push source code to GitHub repository
  git add .
  $version = get-content ./version
  git commit -m $version
  $currentGitBranch = git branch --show-current
  git push origin $currentGitBranch
  write-output "Push source code to GitHub repository done"

  invoke-command ${function:GitMaster}
  write-warning 'You have pushed source code and switched back to Master branch'

  # Save log to ./current-gitlog file
  set-content -path './current-gitlog' -value $null
  git log --all --graph > current-gitlog
  write-output "Save log to ./current-gitlog file done"
  write-warning 'You have run the action GitPush'
}

function GitRefresh {
  set-location .\modules\module-github\
  terraform plan -refresh-only
  set-location ../../
  write-output "Git refresh done"
  write-warning 'You have run the action GitRefresh'
}

function GitDestroy {
  set-location .\modules\module-github\
  terraform destroy --auto-approve
  set-location ../../
  if (test-path -path './.git') {remove-item -recurse -force .git} else {
    write-warning 'Git is being destroyed...'
  }
  write-output "Git destroy done"
  write-warning 'You have run the action GitDestroy'
}

function Confirm {
  $title = "Are you sure you want to confirm this action"
  $message = "Type either 'yes' or 'no'"
  $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "This means Yes"
  $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "This means No"
  $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
  $result = $host.ui.PromptForChoice($title, $message, $options, 0)
  
  Switch ($result)
    {
      0 { continue }
      1 { exit }
    }
  write-warning 'You have run the action Confirm'
}

function Action {
  # [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true, HelpMessage="Enter an action here:")]
    [AllowEmptyString()][AllowNull()]
    [String] $input_act,
    $input_arr = $input_act.Split(' '),
    $null_param = 0,
    $wrong_param = 0,
    $act_arr = @(
      "apply",
      "refresh",
      "destroy",
      "git-push",
      "git-apply",
      "git-refresh",
      "git-destroy",
      "confirm",
      "git-master",
      "git-dev",
      "git-prod"
    )
  )

  try {
    for (($i = 0); $i -le ($input_arr.Length - 1); $i++) {
      for (($j = 0); $j -le ($act_arr.Length - 1); $j++) {
        if (($input_arr[$i] -ieq $act_arr[$j]) -and ($j -eq 0)) {
          invoke-command ${function:Apply}
          break
        }
        if (($input_arr[$i] -ieq $act_arr[$j]) -and ($j -eq 1)) {
          invoke-command ${function:Refresh}
          break
        }
        if (($input_arr[$i] -ieq $act_arr[$j]) -and ($j -eq 2)) {
          invoke-command ${function:Destroy}
          break
        }
        if (($input_arr[$i] -ieq $act_arr[$j]) -and ($j -eq 3)) {
          invoke-command ${function:VersionUp}
          invoke-command ${function:GitPush}
          break
        }
        if (($input_arr[$i] -ieq $act_arr[$j]) -and ($j -eq 4)) {
          invoke-command ${function:GitApply}
          break
        }
        if (($input_arr[$i] -ieq $act_arr[$j]) -and ($j -eq 5)) {
          invoke-command ${function:GitRefresh}
          break
        }
        if (($input_arr[$i] -ieq $act_arr[$j]) -and ($j -eq 6)) {
          invoke-command ${function:GitDestroy}
          break
        }
        if (($input_arr[$i] -ieq $act_arr[$j]) -and ($j -eq 7)) {
          invoke-command ${function:Confirm}
          break
        }
        if (($input_arr[$i] -ieq $act_arr[$j]) -and ($j -eq 8)) {
          invoke-command ${function:GitMaster}
          break
        }
        if (($input_arr[$i] -ieq $act_arr[$j]) -and ($j -eq 9)) {
          invoke-command ${function:GitDev}
          break
        }
        if (($input_arr[$i] -ieq $act_arr[$j]) -and ($j -eq 10)) {
          invoke-command ${function:GitProd}
          break
        }
        if (($input_arr[$i] -eq '') -or ($null -eq $input_arr[$i])) {
          $null_param += 1
          break
        }
        if ($act_arr -inotcontains $input_arr[$i]) {
          $wrong_param += 1
          break
        }
      }
      if ($act_arr -icontains $input_arr[$i]) {
        $act_done = [System.String]::Join(' ', $input_arr[0..$i])
        write-output "Actions have been done:"$act_done
        write-output "Actions pipeline:"$input_act
      }
    }
    if (($null_param -ge 1) -and ($input_arr.Length -ge 1) -and ($wrong_param -eq 0)) {
      write-output "Oke Thankiu! Not any action has been submitted yet"
    }
    if (($wrong_param -ge 1) -and ($input_arr.Length -ge 1)) {
      write-output "Your action must be one of these following:"${act_arr}
    }
  }
  catch {
    write-warning "Opps! Something wrong"
  }
}

Action
