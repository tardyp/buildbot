###
  Recent storage service
###

angular.module('app')
.factory 'recentStorage',
    ['$q', '$window', '$rootScope', ($q, $window, $rootScope) ->
      self = this

      db = null
      setUp = false
      self =
        open : ->
          if setUp
            return $q.when(true)

          deferred = $q.defer()

          if 'indexedDB' of $window
            indexedDB = $window.indexedDB
          else if !setUp
            $rootScope.$apply ->
              deferred.reject('IndexedDB is not supported')
            return deferred.promise

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
          self.open().then ->
            transaction = db.transaction([link], 'readwrite')
            store = transaction.objectStore(link)
            store.add(recent)


        addBuild: (build) ->
          service.addRecent('recent_builds', build)

        addBuilder: (builder) ->
          service.addRecent('recent_builders', builder)

        getRecentLinks: (link) ->
          deferred = $q.defer()

          self.open().then ->
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
          , (e) ->
            $rootScope.$apply ->
              deferred.reject(e)

          return deferred.promise

        getBuilds: ->
          service.getRecentLinks('recent_builds')

        getBuilders: ->
          service.getRecentLinks('recent_builders')

        getAll: ->
          $q.all {
            recent_builds: service.getBuilds(),
            recent_builders: service.getBuilders()
          }

        clear: (link) ->
          self.open().then ->
            transaction = db.transaction([link], 'readwrite')
            store = transaction.objectStore(link)
            store.clear()
            return service.getAll()

        clearAll: ->
          service.clear('recent_builds')
          service.clear('recent_builders')

      return service
    ]