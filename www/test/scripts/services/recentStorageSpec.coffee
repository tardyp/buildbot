if window.__karma__?
    beforeEach module 'app'

    describe 'recent storage service', ->
        recentStorage = $q = $window = null

        injected = ($injector) ->
            $q = $injector.get('$q')
            $window = $injector.get('$window')
            recentStorage = $injector.get('recentStorage')

        beforeEach (inject(injected))

        it 'should store recent builds', (done) ->
            testBuild1 = {link: '/test1', caption: 'test1'}
            testBuild2 = {link: '/test2', caption: 'test2'}
            testBuild3 = {link: '/test3', caption: 'test3'}
            dump testBuild1
            recentStorage.addBuild(testBuild1)
            recentStorage.addBuild(testBuild3)
            recentStorage.getBuilds().then (e) ->
                dump e
                resolved = e
                expect(resolved).not.toBeNull()
                expect(resolved).toContain(testBuild1)
                expect(resolved).toContain(testBuild3)
                expect(resolved).not.toContain(testBuild2)
                done()
            , ->
                dump "failed", testBuild1
                done()

        it 'should store recent builders', (done) ->
            testBuilder1 = {link: '/test1', caption: 'test1'}
            testBuilder2 = {link: '/test2', caption: 'test2'}
            testBuilder3 = {link: '/test3', caption: 'test3'}

            recentStorage.addBuilder(testBuilder1)
            recentStorage.addBuilder(testBuilder2)
            promise = recentStorage.getBuilders()
            promise.then (e) ->
                resolved = e
                expect(resolved).not.toBeNull()
                expect(resolved).toContain(testBuilder1)
                expect(resolved).toContain(testBuilder2)
                expect(resolved).not.toContain(testBuilder3)
            , ->
                done()

        it 'should be empty after clear', (done) ->
            recentStorage.clearAll().then (e) ->
                resolved = e
                expect(resolved.recent_builds.length).toBe(0)
                expect(resolved.recent_builders.length).toBe(0)
                done()
            , ->
                done()