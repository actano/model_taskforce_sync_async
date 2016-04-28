immutable = require 'immutable'

class Acl extends immutable.Record(entries: new immutable.Set())
    add: (principalId, permission) ->
        entry = @createEntry principalId, permission
        @set 'entries', @entries.add entry

    delete: (principalId, permission) ->
        entry = @createEntry principalId, permission

        unless @entries.has entry
            throw Error 'bla'

        @set 'entries', @entries.delete entry

    update: (principalId, oldPermission, newPermission) ->
        @withMutations (acl) ->
            acl.delete principalId, oldPermission
            acl.add principalId, newPermission

    hasEntry: (principalId, permission) ->
        entry = @createEntry principalId, permission
        return @entries.has entry

    createEntry: (principalId, permission) ->
        immutable.Map {principalId, permission}


class Node extends immutable.Record(
    id: null,
    parentId: null,
    acl: new Acl())

module.exports = {Node, Acl}