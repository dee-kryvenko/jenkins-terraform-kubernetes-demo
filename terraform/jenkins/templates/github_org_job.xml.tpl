      <?xml version='1.1' encoding='UTF-8'?>
      <jenkins.branch.OrganizationFolder plugin="branch-api@2.1.2">
        <actions/>
        <description></description>
        <displayName>${org}</displayName>
        <properties>
          <jenkins.branch.NoTriggerOrganizationFolderProperty>
            <branches>.*</branches>
          </jenkins.branch.NoTriggerOrganizationFolderProperty>
          <org.jenkinsci.plugins.pipeline.modeldefinition.config.FolderConfig plugin="pipeline-model-definition@1.3.4">
            <dockerLabel></dockerLabel>
            <registry plugin="docker-commons@1.13"/>
          </org.jenkinsci.plugins.pipeline.modeldefinition.config.FolderConfig>
        </properties>
        <folderViews class="jenkins.branch.OrganizationFolderViewHolder">
          <owner reference="../.."/>
        </folderViews>
        <healthMetrics>
          <com.cloudbees.hudson.plugins.folder.health.WorstChildHealthMetric plugin="cloudbees-folder@6.7">
            <nonRecursive>false</nonRecursive>
          </com.cloudbees.hudson.plugins.folder.health.WorstChildHealthMetric>
        </healthMetrics>
        <icon class="jenkins.branch.MetadataActionFolderIcon">
          <owner class="jenkins.branch.OrganizationFolder" reference="../.."/>
        </icon>
        <orphanedItemStrategy class="com.cloudbees.hudson.plugins.folder.computed.DefaultOrphanedItemStrategy" plugin="cloudbees-folder@6.7">
          <pruneDeadBranches>true</pruneDeadBranches>
          <daysToKeep>-1</daysToKeep>
          <numToKeep>5</numToKeep>
        </orphanedItemStrategy>
        <triggers/>
        <disabled>false</disabled>
        <navigators>
          <org.jenkinsci.plugins.github__branch__source.GitHubSCMNavigator plugin="github-branch-source@2.4.1">
            <repoOwner>${org}</repoOwner>
            <credentialsId>github_token</credentialsId>
            <traits>
              <jenkins.scm.impl.trait.WildcardSCMSourceFilterTrait plugin="scm-api@2.3.0">
                <includes>jenkins-terraform-kubernetes-demo*</includes>
                <excludes></excludes>
              </jenkins.scm.impl.trait.WildcardSCMSourceFilterTrait>
              <org.jenkinsci.plugins.github__branch__source.BranchDiscoveryTrait>
                <strategyId>1</strategyId>
              </org.jenkinsci.plugins.github__branch__source.BranchDiscoveryTrait>
              <org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait>
                <strategyId>1</strategyId>
              </org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait>
              <org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait>
                <strategyId>1</strategyId>
                <trust class="org.jenkinsci.plugins.github_branch_source.ForkPullRequestDiscoveryTrait$TrustNobody"/>
              </org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait>
            </traits>
          </org.jenkinsci.plugins.github__branch__source.GitHubSCMNavigator>
        </navigators>
        <projectFactories>
          <org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProjectFactory plugin="workflow-multibranch@2.20">
            <scriptPath>Jenkinsfile</scriptPath>
          </org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProjectFactory>
        </projectFactories>
        <buildStrategies/>
      </jenkins.branch.OrganizationFolder>