Promise = require 'bluebird'

checkPermission = (node, user, permission) ->
    unless node?
        return false

    if node.acl.hasEntry user, permission
        return true

    parent = yield load node.parentId
    return yield from checkPermission parent, user, permission

load = (id) -> {id: id, type: 'load'}


syncExecution = (func, strategy) -> (store, args...) ->
    iterator = func args...
    effectResult = null
    until (effect = iterator.next(effectResult)).done
        effectResult = strategy store, effect.value

    return effect.value

syncStrategy = (store, effect) ->
    switch effect.type
        when 'load'
            store.get effect.id


asyncExecution = (func, strategy) -> Promise.coroutine (store, args...) ->
    iterator = func args...
    effectResult = null
    until (effect = iterator.next(effectResult)).done
        effectResult = yield strategy store, effect.value

    return effect.value

asyncStrategy = (store, effect) ->
    switch effect.type
        when 'load'
            Promise.resolve(store.get effect.id).delay(500)


syncCheckPermission = syncExecution checkPermission, syncStrategy
asyncCheckPermission = asyncExecution checkPermission, asyncStrategy

module.exports = {syncCheckPermission, asyncCheckPermission}