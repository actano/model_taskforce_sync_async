{expect} = require 'chai'
    .use require 'chai-as-promised'
Promise = require 'bluebird'
immutable = require 'immutable'
{Node, Acl} = require '../model'
{syncCheckPermission, asyncCheckPermission} = require '../checkPermission'

describe 'check permission', ->
    nodeStore = null
    a_2 = null
    a_3 = null

    before 'create store', ->
        nodeStore = immutable.Map()

        acl = new Acl().add 'patty', 'read'
        a_1 = new Node {id: 'A_1', acl: acl}
        nodeStore = nodeStore.set a_1.id, a_1

        a_2 = new Node {id: 'A_2', parentId: 'A_1'}
        nodeStore = nodeStore.set a_2.id, a_2

        acl = new Acl().add 'chris', 'read'
        a_3 = new Node {id: 'A_3', parentId: 'A_2', acl: acl}
        nodeStore = nodeStore.set a_3.id, a_3

    describe 'sync', ->
        it 'should fail for Marcus on A_3', ->
            result = syncCheckPermission nodeStore, a_3, 'marcus', 'read'
            expect(result).be.false

        it 'should pass for Chris on A_3', ->
            result = syncCheckPermission nodeStore, a_3, 'chris', 'read'
            expect(result).be.true

        it 'should pass for Patty on A_3', ->
            result = syncCheckPermission nodeStore, a_3, 'patty', 'read'
            expect(result).be.true

    describe 'async', ->
        it 'should fail for marcus on A_3', Promise.coroutine ->
            result = yield asyncCheckPermission nodeStore, a_3, 'marcus', 'read'
            expect(result).be.false

        it 'should pass for Chris on A_3', Promise.coroutine ->
            result = yield asyncCheckPermission nodeStore, a_3, 'chris', 'read'
            expect(result).be.true

        it 'should pass for Patty on A_3', Promise.coroutine ->
            result = yield asyncCheckPermission nodeStore, a_3, 'patty', 'read'
            expect(result).be.true
