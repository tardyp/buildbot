if window.__karma__?
    beforeEach module 'app'

    describe 'recent storage service', ->
        recentStorage = $q = $window = $rootScope = null

        injected = ($injector) ->
            $q = $injector.get('$q')
            $window = $injector.get('$window')
            $rootScope = $injector.get('$rootScope')
            recentStorage = $injector.get('recentStorage')

        beforeEach (inject(injected))

        it 'should store recent builds', (done) ->
            testBuild1 = {link: '/test1', caption: 'test1'}
            testBuild2 = {link: '/test2', caption: 'test2'}
            testBuild3 = {link: '/test3', caption: 'test3'}

            # first make sure everything is clear
            recentStorage.clearAll().then (e) ->
                $q.all([
                    recentStorage.addBuild(testBuild1),
                    recentStorage.addBuild(testBuild3)
                ])
                .then ->
                    recentStorage.getBuilds().then (e) ->
                        resolved = e
                        console.log e
                        expect(resolved).not.toBeNull()
                        expect(resolved).toContain(testBuild1)
                        expect(resolved).toContain(testBuild3)
                        expect(resolved).not.toContain(testBuild2)
                        done()
            , ->
                # make sure if that failed, its because the browser did not support it
                expect(window.indexedDB).toBeUndefined()
                done()
            $rootScope.$digest()
###
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
            $rootScope.$digest()

        it 'should be empty after clear', (done) ->
            recentStorage.clearAll().then (e) ->
                resolved = e
                expect(resolved.recent_builds.length).toBe(0)
                expect(resolved.recent_builders.length).toBe(0)
                done()
            , ->
                done()
            $rootScope.$digest()

###

