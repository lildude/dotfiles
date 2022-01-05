#compdef _op op


function _op {
  local -a commands

  _arguments -C \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '(-h --help)'{-h,--help}'[get help for op]' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "add:Grant access to groups or vaults"
      "completion:Generate shell completion information"
      "confirm:Confirm a user"
      "create:Create an object"
      "delete:Remove an object"
      "edit:Edit an object"
      "encode:Encode the JSON needed to create an item"
      "forget:Remove a 1Password account from this device"
      "get:Get details about an object"
      "help:Get help for a command"
      "list:List objects and events"
      "manage:Manage group access to 1Password integrations"
      "reactivate:Reactivate a suspended user"
      "remove:Revoke access to groups or vaults"
      "signin:Sign in to a 1Password account"
      "signout:Sign out of a 1Password account"
      "suspend:Suspend a user"
      "update:Check for and download updates"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  add)
    _op_add
    ;;
  completion)
    _op_completion
    ;;
  confirm)
    _op_confirm
    ;;
  create)
    _op_create
    ;;
  delete)
    _op_delete
    ;;
  edit)
    _op_edit
    ;;
  encode)
    _op_encode
    ;;
  forget)
    _op_forget
    ;;
  get)
    _op_get
    ;;
  help)
    _op_help
    ;;
  list)
    _op_list
    ;;
  manage)
    _op_manage
    ;;
  reactivate)
    _op_reactivate
    ;;
  remove)
    _op_remove
    ;;
  signin)
    _op_signin
    ;;
  signout)
    _op_signout
    ;;
  suspend)
    _op_suspend
    ;;
  update)
    _op_update
    ;;
  esac
}


function _op_add {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with add]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "connect:Grant access to vaults to 1Password Secrets Automation"
      "group:Grant a group access to a vault"
      "user:Grant a user access to a vault or group"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  connect)
    _op_add_connect
    ;;
  group)
    _op_add_group
    ;;
  user)
    _op_add_user
    ;;
  esac
}


function _op_add_connect {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with add connect]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "server:Grant a Connect server access to a vault"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  server)
    _op_add_connect_server
    ;;
  esac
}

function _op_add_connect_server {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with add connect server]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_add_group {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with add group]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_add_user {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with add user]' \
    '--role[set the user'\''s `role` in a group (member or manager) (default "member")]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_completion {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with completion]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_confirm {
  _arguments \
    '--all[confirm all unconfirmed users]' \
    '(-h --help)'{-h,--help}'[get help with confirm]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}


function _op_create {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with create]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "connect:Create 1Password Connect servers and tokens"
      "document:Create a document"
      "group:Create a group"
      "integration:Create an integration"
      "item:Create an item"
      "user:Create a user"
      "vault:Create a vault"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  connect)
    _op_create_connect
    ;;
  document)
    _op_create_document
    ;;
  group)
    _op_create_group
    ;;
  integration)
    _op_create_integration
    ;;
  item)
    _op_create_item
    ;;
  user)
    _op_create_user
    ;;
  vault)
    _op_create_vault
    ;;
  esac
}


function _op_create_connect {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with create connect]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "server:Set up a 1Password Connect server"
      "token:Issue a token for a 1Password Connect server"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  server)
    _op_create_connect_server
    ;;
  token)
    _op_create_connect_token
    ;;
  esac
}

function _op_create_connect_server {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with create connect server]' \
    '*--vaults[grant the Connect server access to these `vaults`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_create_connect_token {
  _arguments \
    '--expires-in[set how the long token is valid for]:' \
    '(-h --help)'{-h,--help}'[get help with create connect token]' \
    '*--vault[grant access to this `vault`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_create_document {
  _arguments \
    '--filename[set the file'\''s `name`]:' \
    '(-h --help)'{-h,--help}'[get help with create document]' \
    '--tags[add one or more `tags` (comma-separated) to the item]:' \
    '--title[set the item'\''s `title`]:' \
    '--vault[save the document in this `vault`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_create_group {
  _arguments \
    '--description[set the group'\''s `description`]:' \
    '(-h --help)'{-h,--help}'[get help with create group]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}


function _op_create_integration {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with create integration]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "events-api:Create an Events API integration"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  events-api)
    _op_create_integration_events-api
    ;;
  esac
}

function _op_create_integration_events-api {
  _arguments \
    '--expires-in[set how the long the integration token is valid for]:' \
    '*--features[set the comma-sepparated list of `features` the integration token can be used for. Options: `signinattempts`, `itemusages`]:' \
    '(-h --help)'{-h,--help}'[get help with create integration events-api]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_create_item {
  _arguments \
    '--generate-password[give the item a randomly generated password]' \
    '(-h --help)'{-h,--help}'[get help with create item]' \
    '--tags[add one or more `tags` (comma-separated) to the item]:' \
    '--template[specify the filepath to read an item template from]:' \
    '--title[set the item'\''s `title`]:' \
    '--url[set the `URL` associated with the item]:' \
    '--vault[save the item in this `vault`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_create_user {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with create user]' \
    '--language[set the user'\''s account `language`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_create_vault {
  _arguments \
    '--allow-admins-to-manage[set whether admins can manage vault access]:' \
    '--description[set the vault'\''s `description`]:' \
    '(-h --help)'{-h,--help}'[get help with create vault]' \
    '--icon[set the vault icon]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}


function _op_delete {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with delete]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "connect:Remove 1Password Connect servers and tokens"
      "document:Delete or archive a Document"
      "group:Remove a group"
      "item:Delete or archive an item"
      "user:Completely remove a user"
      "vault:Remove a vault"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  connect)
    _op_delete_connect
    ;;
  document)
    _op_delete_document
    ;;
  group)
    _op_delete_group
    ;;
  item)
    _op_delete_item
    ;;
  user)
    _op_delete_user
    ;;
  vault)
    _op_delete_vault
    ;;
  esac
}


function _op_delete_connect {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with delete connect]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "server:Remove a 1Password Connect server"
      "token:Revoke a token for a Connect server"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  server)
    _op_delete_connect_server
    ;;
  token)
    _op_delete_connect_token
    ;;
  esac
}

function _op_delete_connect_server {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with delete connect server]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_delete_connect_token {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with delete connect token]' \
    '--server[only look for tokens for this 1Password Connect server]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_delete_document {
  _arguments \
    '--archive[move the document to the Archive]' \
    '(-h --help)'{-h,--help}'[get help with delete document]' \
    '--vault[look for the document in this `vault`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_delete_group {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with delete group]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_delete_item {
  _arguments \
    '--archive[move the item to the Archive]' \
    '(-h --help)'{-h,--help}'[get help with delete item]' \
    '--vault[look for the item in this `vault`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_delete_user {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with delete user]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_delete_vault {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with delete vault]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}


function _op_edit {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with edit]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "connect:Edit 1Password Connect servers and tokens"
      "document:Edit a document"
      "group:Edit a group's name or description"
      "item:Edit an item's details"
      "user:Edit a user's name or Travel Mode status"
      "vault:Edit a vault's metadata"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  connect)
    _op_edit_connect
    ;;
  document)
    _op_edit_document
    ;;
  group)
    _op_edit_group
    ;;
  item)
    _op_edit_item
    ;;
  user)
    _op_edit_user
    ;;
  vault)
    _op_edit_vault
    ;;
  esac
}


function _op_edit_connect {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with edit connect]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "server:Rename a Connect server"
      "token:Rename a Connect token"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  server)
    _op_edit_connect_server
    ;;
  token)
    _op_edit_connect_token
    ;;
  esac
}

function _op_edit_connect_server {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with edit connect server]' \
    '--name[change the server'\''s `name`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_edit_connect_token {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with edit connect token]' \
    '--name[change the tokens'\''s `name`]:' \
    '--server[only look for tokens for this 1Password Connect server]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_edit_document {
  _arguments \
    '--filename[set the file'\''s `name`]:' \
    '(-h --help)'{-h,--help}'[get help with edit document]' \
    '--tags[add one or more `tags` (comma-separated) to the item]:' \
    '--title[set the item'\''s `title`]:' \
    '--vault[look up document in this `vault`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_edit_group {
  _arguments \
    '--description[change the group'\''s `description`]:' \
    '(-h --help)'{-h,--help}'[get help with edit group]' \
    '--name[change the group'\''s `name`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_edit_item {
  _arguments \
    '--generate-password[give the item a randomly generated password]' \
    '(-h --help)'{-h,--help}'[get help with edit item]' \
    '--vault[look for the item in this `vault`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_edit_user {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with edit user]' \
    '--name[set the user'\''s `name`]:' \
    '--travelmode[turn Travel Mode on or off for the user]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_edit_vault {
  _arguments \
    '--description[change the vault'\''s `description`]:' \
    '(-h --help)'{-h,--help}'[get help with edit vault]' \
    '--icon[change the vault'\''s `icon`]:' \
    '--name[change the vault'\''s `name`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_encode {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with encode]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_forget {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with forget]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}


function _op_get {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with get]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "account:Get details about your account"
      "document:Download a document"
      "group:Get details about a group"
      "item:Get item details"
      "template:Get an item template"
      "totp:Get the one-time password for an item"
      "user:Get details about a user"
      "vault:Get details about a vault"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  account)
    _op_get_account
    ;;
  document)
    _op_get_document
    ;;
  group)
    _op_get_group
    ;;
  item)
    _op_get_item
    ;;
  template)
    _op_get_template
    ;;
  totp)
    _op_get_totp
    ;;
  user)
    _op_get_user
    ;;
  vault)
    _op_get_vault
    ;;
  esac
}

function _op_get_account {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with get account]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_get_document {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with get document]' \
    '--include-archive[include items in the Archive]' \
    '--output[save the document to the file `path` instead of stdout]:' \
    '--vault[look for the document in this `vault`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_get_group {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with get group]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_get_item {
  _arguments \
    '*--fields[only return data from these `fields`]:' \
    '--format[return data in this `format` (CSV or JSON) (use with --fields)]:' \
    '(-h --help)'{-h,--help}'[get help with get item]' \
    '--include-archive[include items in the Archive]' \
    '--share-link[get a shareable link for the item]' \
    '--vault[look for the item in this `vault`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_get_template {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with get template]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_get_totp {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with get totp]' \
    '--vault[look for the item in this `vault`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_get_user {
  _arguments \
    '--fingerprint[get the user'\''s public key fingerprint]' \
    '(-h --help)'{-h,--help}'[get help with get user]' \
    '--publickey[get the user'\''s public key]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_get_vault {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with get vault]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_help {
  _arguments \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}


function _op_list {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with list]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "connect:List 1Password Connect servers and tokens"
      "documents:Get a list of documents"
      "events:Get a list of events from the Activity Log"
      "groups:Get a list of groups"
      "items:Get a list of items"
      "templates:Get a list of templates"
      "users:Get the list of users"
      "vaults:Get a list of vaults"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  connect)
    _op_list_connect
    ;;
  documents)
    _op_list_documents
    ;;
  events)
    _op_list_events
    ;;
  groups)
    _op_list_groups
    ;;
  items)
    _op_list_items
    ;;
  templates)
    _op_list_templates
    ;;
  users)
    _op_list_users
    ;;
  vaults)
    _op_list_vaults
    ;;
  esac
}


function _op_list_connect {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with list connect]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "servers:Get a list of 1Password Connect servers"
      "tokens:Get a list of tokens"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  servers)
    _op_list_connect_servers
    ;;
  tokens)
    _op_list_connect_tokens
    ;;
  esac
}

function _op_list_connect_servers {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with list connect servers]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_list_connect_tokens {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with list connect tokens]' \
    '--server[only list tokens for this Connect `server`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_list_documents {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with list documents]' \
    '--include-archive[include items in the Archive]' \
    '--vault[only list documents in this `vault`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_list_events {
  _arguments \
    '--eventid[start listing from event with ID `eid`]:' \
    '(-h --help)'{-h,--help}'[get help with list events]' \
    '--older[list events from before the specified event]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_list_groups {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with list groups]' \
    '--user[list groups that a `user` belongs to]:' \
    '--vault[list groups that have direct access to a `vault`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_list_items {
  _arguments \
    '*--categories[only list items in these `categories` (comma-separated)]:' \
    '(-h --help)'{-h,--help}'[get help with list items]' \
    '--include-archive[include items in the Archive]' \
    '*--tags[only list items with these `tags` (comma-separated)]:' \
    '--vault[only list items in this `vault`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_list_templates {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with list templates]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_list_users {
  _arguments \
    '--group[list users who belong to a `group`]:' \
    '(-h --help)'{-h,--help}'[get help with list users]' \
    '--vault[list users who have direct access to `vault`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_list_vaults {
  _arguments \
    '--group[list vaults a `group` has access to]:' \
    '(-h --help)'{-h,--help}'[get help with list vaults]' \
    '--user[list vaults a `user` has access to]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}


function _op_manage {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with manage]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "connect:Manage group access to 1Password Secrets Automation"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  connect)
    _op_manage_connect
    ;;
  esac
}


function _op_manage_connect {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with manage connect]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "add:Grant access to manage Secrets Automation"
      "remove:Revoke access to manage Secrets Automation"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  add)
    _op_manage_connect_add
    ;;
  remove)
    _op_manage_connect_remove
    ;;
  esac
}

function _op_manage_connect_add {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with manage connect add]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_manage_connect_remove {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with manage connect remove]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_reactivate {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with reactivate]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}


function _op_remove {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with remove]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "connect:Remove access to vaults from 1Password Connect servers"
      "group:Revoke a group's access to a vault"
      "user:Revoke a user's access to a vault or group"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  connect)
    _op_remove_connect
    ;;
  group)
    _op_remove_group
    ;;
  user)
    _op_remove_user
    ;;
  esac
}


function _op_remove_connect {
  local -a commands

  _arguments -C \
    '(-h --help)'{-h,--help}'[get help with remove connect]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "server:Revoke a Connect server's access to a vault"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  server)
    _op_remove_connect_server
    ;;
  esac
}

function _op_remove_connect_server {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with remove connect server]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_remove_group {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with remove group]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_remove_user {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with remove user]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_signin {
  _arguments \
    '(-h --help)'{-h,--help}'[get help with signin]' \
    '(-l --list)'{-l,--list}'[list accounts set up on this device]' \
    '(-r --raw)'{-r,--raw}'[only return the session token]' \
    '--shorthand[set the short account `name`]:' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_signout {
  _arguments \
    '--forget[remove the details for a 1Password account from this device]' \
    '(-h --help)'{-h,--help}'[get help with signout]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_suspend {
  _arguments \
    '--deauthorize-devices[deauthorize the user'\''s devices after a time in `seconds`]' \
    '(-h --help)'{-h,--help}'[get help with suspend]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

function _op_update {
  _arguments \
    '--directory[download the update to this `path`]:' \
    '(-h --help)'{-h,--help}'[get help with update]' \
    '--account[use the account with this `shorthand`]:' \
    '--cache[store and use cached information]' \
    '--config[use this configuration `directory`]:' \
    '--encoding[use this character encoding `type`]:' \
    '--session[authenticate with this session `token`]:'
}

