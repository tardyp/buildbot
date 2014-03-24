###
    Recent storage service
###

angular.module('app').factory 'recentStorage',
    ['$q', '$window', '$rootScope', ($q, $window, $rootScope) ->
        self = this

        db = null
        setUp = false
        self =
            open: ->
                if not $window.indexedDB?
                    return $q.reject('IndexedDB is not supported')

                if setUp
                    return $q.when(true)

                deferred = $q.defer()
                indexedDB = $window.indexedDB

                openRequest = indexedDB.open('Recent', 1)
                openRequest.onupgradeneeded = (e) ->
                    thisDB = e.target.result

                    if not thisDB.objectStoreNames.contains('recent_builders')
                        thisDB.createObjectStore 'recent_builders', { keyPath: 'link' }
                    if not thisDB.objectStoreNames.contains('recent_builds')
                        thisDB.createObjectStore 'recent_builds', { keyPath: 'link' }

                openRequest.onsuccess = (e) ->
                    db = e.target.result
                    setUp = true
                    $rootScope.$apply ->
                        deferred.resolve(true)

                openRequest.onerror = (e) ->
                    $rootScope.$apply ->
                        deferred.reject('Database error:' + e.toString())

                return deferred.promise

        service =
            addRecent: (link, recent) ->
                return self.open().then ->
                    transaction = db.transaction([link], 'readwrite')
                    store = transaction.objectStore(link)
                    store.add(recent)

            addBuild: (build) ->
                return service.addRecent('recent_builds', build)

            addBuilder: (builder) ->
                return service.addRecent('recent_builders', builder)

            getRecentLinks: (link) ->
                return self.open().then ->
                    deferred = $q.defer()

                    transaction = db.transaction([link], 'readwrite')
                    store = transaction.objectStore(link)
                    cursorRequest = store.openCursor()

                    cursorRequest.onerror = (e) ->
                        $rootScope.$apply ->
                            deferred.reject('Database error:' + e.toString())

                    recents = []
                    cursorRequest.onsuccess = (e) ->
                        cursor = e.target.result
                        if cursor?
                            recents.push(cursor.value)
                            cursor.continue()

                    transaction.oncomplete = ->
                        $rootScope.$apply ->
                            deferred.resolve(recents)

                    return deferred.promise

            getBuilds: ->
                return service.getRecentLinks('recent_builds')

            getBuilders: ->
                return service.getRecentLinks('recent_builders')

            getAll: ->
                return $q.all {
                    recent_builds: service.getBuilds(),
                    recent_builders: service.getBuilders()
                }

            clear: (link) ->
                return self.open().then ->
                    deferred = $q.defer()
                    transaction = db.transaction([link], 'readwrite')
                    store = transaction.objectStore(link)
                    req = store.clear()
                    req.onerror = (e) ->
                        $rootScope.$apply ->
                            deferred.reject('Database error:' + e.toString())

                    req.onsuccess = (e) ->
                        $rootScope.$apply ->
                            deferred.resolve(null)
                    return deferred.promise

            clearAll: ->
                return $q.all [
                    service.clear('recent_builds')
                    service.clear('recent_builders')
                ]

        return service
    ]