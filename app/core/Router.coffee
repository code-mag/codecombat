# dynamicRequire = require('lib/dynamicRequire')

go = (path, options) -> -> @routeDirectly path, arguments, options

redirect = (path) -> ->
  delete window.alreadyLoadedView
  @navigate(path + document.location.search, { trigger: true, replace: true })

utils = require './utils'
ViewLoadTimer = require 'core/ViewLoadTimer'

module.exports = class CocoRouter extends Backbone.Router

  initialize: ->
    # http://nerds.airbnb.com/how-to-add-google-analytics-page-tracking-to-57536
    @bind 'route', @_trackPageView
    Backbone.Mediator.subscribe 'router:navigate', @onNavigate, @
    @initializeSocialMediaServices = _.once @initializeSocialMediaServices

  routes:
    '': ->
      if window.serverConfig.picoCTF
        return @routeDirectly 'play/CampaignView', ['picoctf'], {}
      if utils.getQueryVariable 'hour_of_code'
        return @navigate "/play?hour_of_code=true", {trigger: true, replace: true}
      unless me.isAnonymous() or me.isTeacher() or me.isAdmin() or me.hasSubscription()
        delete window.alreadyLoadedView
        return @navigate "/premium", {trigger: true, replace: true}
      return @routeDirectly('HomeView', [])

    'about': go(require('promise-loader?bluebird!views/AboutView'))

    # 'account': go(require('promise-loader?bluebird!views/account/MainAccountView'))
    'account/settings': go(require('promise-loader?bluebird!views/account/AccountSettingsRootView'))
    'account/unsubscribe': go(require('promise-loader?bluebird!views/account/UnsubscribeView'))
    'account/payments': go(require('promise-loader?bluebird!views/account/PaymentsView'))
    'account/subscription': go(require('promise-loader?bluebird!views/account/SubscriptionView'), { redirectStudents: true, redirectTeachers: true })
    'account/invoices': go(require('promise-loader?bluebird!views/account/InvoicesView'))
    'account/prepaid': go(require('promise-loader?bluebird!views/account/PrepaidView'))

    # 'admin': go((->`import(/* webpackChunkName: "views/admin/MainAdminView" */ 'views/admin/MainAdminView')`))
    # 'admin/clas': go((->`import(/* webpackChunkName: "views/admin/CLAsView" */ 'views/admin/CLAsView')`))
    # 'admin/classroom-content': go((->`import(/* webpackChunkName: "views/admin/AdminClassroomContentView" */ 'views/admin/AdminClassroomContentView')`))
    # 'admin/classroom-levels': go((->`import(/* webpackChunkName: "views/admin/AdminClassroomLevelsView" */ 'views/admin/AdminClassroomLevelsView')`))
    # 'admin/classrooms-progress': go((->`import(/* webpackChunkName: "views/admin/AdminClassroomsProgressView" */ 'views/admin/AdminClassroomsProgressView')`))
    # 'admin/design-elements': go((->`import(/* webpackChunkName: "views/admin/DesignElementsView" */ 'views/admin/DesignElementsView')`))
    # 'admin/files': go((->`import(/* webpackChunkName: "views/admin/FilesView" */ 'views/admin/FilesView')`))
    # 'admin/analytics': go((->`import(/* webpackChunkName: "views/admin/AnalyticsView" */ 'views/admin/AnalyticsView')`))
    # 'admin/analytics/subscriptions': go((->`import(/* webpackChunkName: "views/admin/AnalyticsSubscriptionsView" */ 'views/admin/AnalyticsSubscriptionsView')`))
    # # 'admin/level-sessions': go((->`import(/* webpackChunkName: "views/admin/LevelSessionsView" */ 'views/admin/LevelSessionsView')`))
    # 'admin/school-counts': go((->`import(/* webpackChunkName: "views/admin/SchoolCountsView" */ 'views/admin/SchoolCountsView')`))
    # 'admin/school-licenses': go((->`import(/* webpackChunkName: "views/admin/SchoolLicensesView" */ 'views/admin/SchoolLicensesView')`))
    # 'admin/base': go((->`import(/* webpackChunkName: "views/admin/BaseView" */ 'views/admin/BaseView')`))
    # 'admin/demo-requests': go((->`import(/* webpackChunkName: "views/admin/DemoRequestsView" */ 'views/admin/DemoRequestsView')`))
    # 'admin/trial-requests': go((->`import(/* webpackChunkName: "views/admin/TrialRequestsView" */ 'views/admin/TrialRequestsView')`))
    # 'admin/user-code-problems': go((->`import(/* webpackChunkName: "views/admin/UserCodeProblemsView" */ 'views/admin/UserCodeProblemsView')`))
    # 'admin/pending-patches': go((->`import(/* webpackChunkName: "views/admin/PendingPatchesView" */ 'views/admin/PendingPatchesView')`))
    # 'admin/codelogs': go((->`import(/* webpackChunkName: "views/admin/CodeLogsView" */ 'views/admin/CodeLogsView')`))
    # 'admin/skipped-contacts': go((->`import(/* webpackChunkName: "views/admin/SkippedContactsView" */ 'views/admin/SkippedContactsView')`))
    # 'admin/outcomes-report-result': go((->`import(/* webpackChunkName: "views/admin/OutcomeReportResultView" */ 'views/admin/OutcomeReportResultView')`))
    # 'admin/outcomes-report': go((->`import(/* webpackChunkName: "views/admin/OutcomesReportView" */ 'views/admin/OutcomesReportView')`))
    #
    # 'artisans': go((->`import(/* webpackChunkName: "views/artisans/ArtisansView" */ 'views/artisans/ArtisansView')`))
    #
    # 'artisans/level-tasks': go((->`import(/* webpackChunkName: "views/artisans/LevelTasksView" */ 'views/artisans/LevelTasksView')`))
    # 'artisans/solution-problems': go((->`import(/* webpackChunkName: "views/artisans/SolutionProblemsView" */ 'views/artisans/SolutionProblemsView')`))
    # 'artisans/thang-tasks': go((->`import(/* webpackChunkName: "views/artisans/ThangTasksView" */ 'views/artisans/ThangTasksView')`))
    # 'artisans/level-concepts': go((->`import(/* webpackChunkName: "views/artisans/LevelConceptMap" */ 'views/artisans/LevelConceptMap')`))
    # 'artisans/level-guides': go((->`import(/* webpackChunkName: "views/artisans/LevelGuidesView" */ 'views/artisans/LevelGuidesView')`))
    # 'artisans/student-solutions': go((->`import(/* webpackChunkName: "views/artisans/StudentSolutionsView" */ 'views/artisans/StudentSolutionsView')`))
    # 'artisans/tag-test': go((->`import(/* webpackChunkName: "views/artisans/TagTestView" */ 'views/artisans/TagTestView')`))
    #
    # 'careers': => window.location.href = 'https://jobs.lever.co/codecombat'
    # 'Careers': => window.location.href = 'https://jobs.lever.co/codecombat'
    #
    # 'cla': go((->`import(/* webpackChunkName: "views/CLAView" */ 'views/CLAView')`))
    #
    # 'clans': go((->`import(/* webpackChunkName: "views/clans/ClansView" */ 'views/clans/ClansView')`))
    # 'clans/:clanID': go((->`import(/* webpackChunkName: "views/clans/ClanDetailsView" */ 'views/clans/ClanDetailsView')`))
    #
    # 'community': go((->`import(/* webpackChunkName: "views/CommunityView" */ 'views/CommunityView')`))
    #
    # 'contribute': go((->`import(/* webpackChunkName: "views/contribute/MainContributeView" */ 'views/contribute/MainContributeView')`))
    # 'contribute/adventurer': go((->`import(/* webpackChunkName: "views/contribute/AdventurerView" */ 'views/contribute/AdventurerView')`))
    # 'contribute/ambassador': go((->`import(/* webpackChunkName: "views/contribute/AmbassadorView" */ 'views/contribute/AmbassadorView')`))
    # 'contribute/archmage': go((->`import(/* webpackChunkName: "views/contribute/ArchmageView" */ 'views/contribute/ArchmageView')`))
    # 'contribute/artisan': go((->`import(/* webpackChunkName: "views/contribute/ArtisanView" */ 'views/contribute/ArtisanView')`))
    # 'contribute/diplomat': go((->`import(/* webpackChunkName: "views/contribute/DiplomatView" */ 'views/contribute/DiplomatView')`))
    # 'contribute/scribe': go((->`import(/* webpackChunkName: "views/contribute/ScribeView" */ 'views/contribute/ScribeView')`))
    #
    # 'courses': redirect('/students') # Redirected 9/3/16
    # 'Courses': redirect('/students') # Redirected 9/3/16
    # 'courses/students': redirect('/students') # Redirected 9/3/16
    # 'courses/teachers': redirect('/teachers/classes')
    # 'courses/purchase': redirect('/teachers/licenses')
    # 'courses/enroll(/:courseID)': redirect('/teachers/licenses')
    # 'courses/update-account': redirect('students/update-account') # Redirected 9/3/16
    # 'courses/:classroomID': -> @navigate("/students/#{arguments[0]}", {trigger: true, replace: true}) # Redirected 9/3/16
    # 'courses/:courseID/:courseInstanceID': -> @navigate("/students/#{arguments[0]}/#{arguments[1]}", {trigger: true, replace: true}) # Redirected 9/3/16
    #
    # 'db/*path': 'routeToServer'
    # 'demo(/*subpath)': go((->`import(/* webpackChunkName: "views/DemoView" */ 'views/DemoView')`))
    # # 'docs/components': go((->`import(/* webpackChunkName: "views/docs/ComponentsDocumentationView" */ 'views/docs/ComponentsDocumentationView')`))
    # # 'docs/systems': go((->`import(/* webpackChunkName: "views/docs/SystemsDocumentationView" */ 'views/docs/SystemsDocumentationView')`))
    #
    # 'editor': go((->`import(/* webpackChunkName: "views/CommunityView" */ 'views/CommunityView')`))
    #
    # 'editor/achievement': go((->`import(/* webpackChunkName: "views/editor/achievement/AchievementSearchView" */ 'views/editor/achievement/AchievementSearchView')`))
    # 'editor/achievement/:articleID': go((->`import(/* webpackChunkName: "views/editor/achievement/AchievementEditView" */ 'views/editor/achievement/AchievementEditView')`))
    # 'editor/article': go((->`import(/* webpackChunkName: "views/editor/article/ArticleSearchView" */ 'views/editor/article/ArticleSearchView')`))
    # 'editor/article/preview': go((->`import(/* webpackChunkName: "views/editor/article/ArticlePreviewView" */ 'views/editor/article/ArticlePreviewView')`))
    # 'editor/article/:articleID': go((->`import(/* webpackChunkName: "views/editor/article/ArticleEditView" */ 'views/editor/article/ArticleEditView')`))
    # 'editor/level': go((->`import(/* webpackChunkName: "views/editor/level/LevelSearchView" */ 'views/editor/level/LevelSearchView')`))
    # 'editor/level/:levelID': go((->`import(/* webpackChunkName: "views/editor/level/LevelEditView" */ 'views/editor/level/LevelEditView')`))
    # 'editor/thang': go((->`import(/* webpackChunkName: "views/editor/thang/ThangTypeSearchView" */ 'views/editor/thang/ThangTypeSearchView')`))
    # 'editor/thang/:thangID': go((->`import(/* webpackChunkName: "views/editor/thang/ThangTypeEditView" */ 'views/editor/thang/ThangTypeEditView')`))
    # 'editor/campaign/:campaignID': go((->`import(/* webpackChunkName: "views/editor/campaign/CampaignEditorView" */ 'views/editor/campaign/CampaignEditorView')`))
    # 'editor/poll': go((->`import(/* webpackChunkName: "views/editor/poll/PollSearchView" */ 'views/editor/poll/PollSearchView')`))
    # 'editor/poll/:articleID': go((->`import(/* webpackChunkName: "views/editor/poll/PollEditView" */ 'views/editor/poll/PollEditView')`))
    # # 'editor/thang-tasks': go((->`import(/* webpackChunkName: "views/editor/ThangTasksView" */ 'views/editor/ThangTasksView')`))
    # 'editor/verifier': go((->`import(/* webpackChunkName: "views/editor/verifier/VerifierView" */ 'views/editor/verifier/VerifierView')`))
    # 'editor/verifier/:levelID': go((->`import(/* webpackChunkName: "views/editor/verifier/VerifierView" */ 'views/editor/verifier/VerifierView')`))
    # 'editor/i18n-verifier/:levelID': go((->`import(/* webpackChunkName: "views/editor/verifier/i18nVerifierView" */ 'views/editor/verifier/i18nVerifierView')`))
    # 'editor/i18n-verifier': go((->`import(/* webpackChunkName: "views/editor/verifier/i18nVerifierView" */ 'views/editor/verifier/i18nVerifierView')`))
    # 'editor/course': go((->`import(/* webpackChunkName: "views/editor/course/CourseSearchView" */ 'views/editor/course/CourseSearchView')`))
    # 'editor/course/:courseID': go((->`import(/* webpackChunkName: "views/editor/course/CourseEditView" */ 'views/editor/course/CourseEditView')`))
    #
    # 'file/*path': 'routeToServer'
    #
    # 'github/*path': 'routeToServer'
    #
    # 'hoc': -> @navigate "/play?hour_of_code=true", {trigger: true, replace: true}
    # 'home': go((->`import(/* webpackChunkName: "views/HomeView" */ 'views/HomeView')`))
    #
    # 'i18n': go((->`import(/* webpackChunkName: "views/i18n/I18NHomeView" */ 'views/i18n/I18NHomeView')`))
    # 'i18n/thang/:handle': go((->`import(/* webpackChunkName: "views/i18n/I18NEditThangTypeView" */ 'views/i18n/I18NEditThangTypeView')`))
    # 'i18n/component/:handle': go((->`import(/* webpackChunkName: "views/i18n/I18NEditComponentView" */ 'views/i18n/I18NEditComponentView')`))
    # 'i18n/level/:handle': go((->`import(/* webpackChunkName: "views/i18n/I18NEditLevelView" */ 'views/i18n/I18NEditLevelView')`))
    # 'i18n/achievement/:handle': go((->`import(/* webpackChunkName: "views/i18n/I18NEditAchievementView" */ 'views/i18n/I18NEditAchievementView')`))
    # 'i18n/campaign/:handle': go((->`import(/* webpackChunkName: "views/i18n/I18NEditCampaignView" */ 'views/i18n/I18NEditCampaignView')`))
    # 'i18n/poll/:handle': go((->`import(/* webpackChunkName: "views/i18n/I18NEditPollView" */ 'views/i18n/I18NEditPollView')`))
    # 'i18n/course/:handle': go((->`import(/* webpackChunkName: "views/i18n/I18NEditCourseView" */ 'views/i18n/I18NEditCourseView')`))
    # 'i18n/product/:handle': go((->`import(/* webpackChunkName: "views/i18n/I18NEditProductView" */ 'views/i18n/I18NEditProductView')`))
    #
    # 'identify': go((->`import(/* webpackChunkName: "views/user/IdentifyView" */ 'views/user/IdentifyView')`))
    # 'il-signup': go((->`import(/* webpackChunkName: "views/account/IsraelSignupView" */ 'views/account/IsraelSignupView')`))
    #
    # 'legal': go((->`import(/* webpackChunkName: "views/LegalView" */ 'views/LegalView')`))
    #
    # 'logout': 'logout'
    #
    # 'paypal/subscribe-callback': go((->`import(/* webpackChunkName: "views/play/CampaignView" */ 'views/play/CampaignView')`))
    # 'paypal/cancel-callback': go((->`import(/* webpackChunkName: "views/account/SubscriptionView" */ 'views/account/SubscriptionView')`))
    #
    # 'play(/)': go((->`import(/* webpackChunkName: "views/play/CampaignView" */ 'views/play/CampaignView')`), { redirectStudents: true, redirectTeachers: true }) # extra slash is to get Facebook app to work
    # 'play/ladder/:levelID/:leagueType/:leagueID': go((->`import(/* webpackChunkName: "views/ladder/LadderView" */ 'views/ladder/LadderView')`))
    # 'play/ladder/:levelID': go((->`import(/* webpackChunkName: "views/ladder/LadderView" */ 'views/ladder/LadderView')`))
    # 'play/ladder': go((->`import(/* webpackChunkName: "views/ladder/MainLadderView" */ 'views/ladder/MainLadderView')`))
    # 'play/level/:levelID': go((->`import(/* webpackChunkName: "views/play/level/PlayLevelView" */ 'views/play/level/PlayLevelView')`))
    # 'play/game-dev-level/:levelID/:sessionID': go((->`import(/* webpackChunkName: "views/play/level/PlayGameDevLevelView" */ 'views/play/level/PlayGameDevLevelView')`))
    # 'play/web-dev-level/:levelID/:sessionID': go((->`import(/* webpackChunkName: "views/play/level/PlayWebDevLevelView" */ 'views/play/level/PlayWebDevLevelView')`))
    # 'play/spectate/:levelID': go((->`import(/* webpackChunkName: "views/play/SpectateView" */ 'views/play/SpectateView')`))
    # 'play/:map': go((->`import(/* webpackChunkName: "views/play/CampaignView" */ 'views/play/CampaignView')`), { redirectTeachers: true })
    #
    # 'premium': go((->`import(/* webpackChunkName: "views/PremiumFeaturesView" */ 'views/PremiumFeaturesView')`))
    # 'Premium': go((->`import(/* webpackChunkName: "views/PremiumFeaturesView" */ 'views/PremiumFeaturesView')`))
    #
    # 'preview': go((->`import(/* webpackChunkName: "views/HomeView" */ 'views/HomeView')`))
    #
    # 'privacy': go((->`import(/* webpackChunkName: "views/PrivacyView" */ 'views/PrivacyView')`))
    #
    # 'schools': go((->`import(/* webpackChunkName: "views/HomeView" */ 'views/HomeView')`))
    # 'seen': go((->`import(/* webpackChunkName: "views/HomeView" */ 'views/HomeView')`))
    # 'SEEN': go((->`import(/* webpackChunkName: "views/HomeView" */ 'views/HomeView')`))
    #
    # 'sunburst': go((->`import(/* webpackChunkName: "views/HomeView" */ 'views/HomeView')`))
    #
    # 'students': go((->`import(/* webpackChunkName: "views/courses/CoursesView" */ 'views/courses/CoursesView')`), { redirectTeachers: true })
    # 'students/update-account': go((->`import(/* webpackChunkName: "views/courses/CoursesUpdateAccountView" */ 'views/courses/CoursesUpdateAccountView')`), { redirectTeachers: true })
    # 'students/project-gallery/:courseInstanceID': go((->`import(/* webpackChunkName: "views/courses/ProjectGalleryView" */ 'views/courses/ProjectGalleryView')`))
    # 'students/:classroomID': go((->`import(/* webpackChunkName: "views/courses/ClassroomView" */ 'views/courses/ClassroomView')`), { redirectTeachers: true, studentsOnly: true })
    # 'students/:courseID/:courseInstanceID': go((->`import(/* webpackChunkName: "views/courses/CourseDetailsView" */ 'views/courses/CourseDetailsView')`), { redirectTeachers: true, studentsOnly: true })
    # 'teachers': redirect('/teachers/classes')
    # 'teachers/classes': go((->`import(/* webpackChunkName: "views/courses/TeacherClassesView" */ 'views/courses/TeacherClassesView')`), { redirectStudents: true, teachersOnly: true })
    # 'teachers/classes/:classroomID/:studentID': go((->`import(/* webpackChunkName: "views/teachers/TeacherStudentView" */ 'views/teachers/TeacherStudentView')`), { redirectStudents: true, teachersOnly: true })
    # 'teachers/classes/:classroomID': go((->`import(/* webpackChunkName: "views/courses/TeacherClassView" */ 'views/courses/TeacherClassView')`), { redirectStudents: true, teachersOnly: true })
    # 'teachers/courses': go((->`import(/* webpackChunkName: "views/courses/TeacherCoursesView" */ 'views/courses/TeacherCoursesView')`), { redirectStudents: true })
    # 'teachers/course-solution/:courseID/:language': go((->`import(/* webpackChunkName: "views/teachers/TeacherCourseSolutionView" */ 'views/teachers/TeacherCourseSolutionView')`), { redirectStudents: true })
    # 'teachers/demo': go((->`import(/* webpackChunkName: "views/teachers/RequestQuoteView" */ 'views/teachers/RequestQuoteView')`), { redirectStudents: true })
    # 'teachers/enrollments': redirect('/teachers/licenses')
    # 'teachers/licenses': go((->`import(/* webpackChunkName: "views/courses/EnrollmentsView" */ 'views/courses/EnrollmentsView')`), { redirectStudents: true, teachersOnly: true })
    # 'teachers/freetrial': go((->`import(/* webpackChunkName: "views/teachers/RequestQuoteView" */ 'views/teachers/RequestQuoteView')`), { redirectStudents: true })
    # 'teachers/quote': redirect('/teachers/demo')
    # 'teachers/resources': go((->`import(/* webpackChunkName: "views/teachers/ResourceHubView" */ 'views/teachers/ResourceHubView')`), { redirectStudents: true })
    # 'teachers/resources/ap-cs-principles': go((->`import(/* webpackChunkName: "views/teachers/ApCsPrinciplesView" */ 'views/teachers/ApCsPrinciplesView')`), { redirectStudents: true })
    # 'teachers/resources/:name': go((->`import(/* webpackChunkName: "views/teachers/MarkdownResourceView" */ 'views/teachers/MarkdownResourceView')`), { redirectStudents: true })
    # 'teachers/signup': ->
    #   return @routeDirectly('teachers/CreateTeacherAccountView', []) if me.isAnonymous()
    #   return @navigate('/students', {trigger: true, replace: true}) if me.isStudent() and not me.isAdmin()
    #   @navigate('/teachers/update-account', {trigger: true, replace: true})
    # 'teachers/starter-licenses': go((->`import(/* webpackChunkName: "views/teachers/StarterLicenseUpsellView" */ 'views/teachers/StarterLicenseUpsellView')`), { redirectStudents: true, teachersOnly: true })
    # 'teachers/update-account': ->
    #   return @navigate('/teachers/signup', {trigger: true, replace: true}) if me.isAnonymous()
    #   return @navigate('/students', {trigger: true, replace: true}) if me.isStudent() and not me.isAdmin()
    #   @routeDirectly('teachers/ConvertToTeacherAccountView', [])
    #
    # 'test(/*subpath)': go((->`import(/* webpackChunkName: "views/TestView" */ 'views/TestView')`))
    #
    # 'user/:slugOrID': go((->`import(/* webpackChunkName: "views/user/MainUserView" */ 'views/user/MainUserView')`))
    # 'user/:userID/verify/:verificationCode': go((->`import(/* webpackChunkName: "views/user/EmailVerifiedView" */ 'views/user/EmailVerifiedView')`))
    #
    # '*name/': 'removeTrailingSlash'
    # '*name': go((->`import(/* webpackChunkName: "views/NotFoundView" */ 'views/NotFoundView')`))

  routeToServer: (e) ->
    window.location.href = window.location.href

  removeTrailingSlash: (e) ->
    @navigate e, {trigger: true}

  routeDirectly: (viewPromiseFn, args=[], options={}) ->
    if window.alreadyLoadedView
      path = window.alreadyLoadedView

    # @viewLoad = new ViewLoadTimer() unless options.recursive
    # if options.redirectStudents and me.isStudent() and not me.isAdmin()
    #   return @redirectHome()
    # if options.redirectTeachers and me.isTeacher() and not me.isAdmin()
    #   return @redirectHome()
    # if options.teachersOnly and not (me.isTeacher() or me.isAdmin())
    #   return @routeDirectly('teachers/RestrictedToTeachersView')
    # if options.studentsOnly and not (me.isStudent() or me.isAdmin())
    #   return @routeDirectly('courses/RestrictedToStudentsView')
    # leavingMessage = _.result(window.currentView, 'onLeaveMessage')
    # if leavingMessage
    #   if not confirm(leavingMessage)
    #     return @navigate(this.path, {replace: true})
    #   else
    #     window.currentView.onLeaveMessage = _.noop # to stop repeat confirm calls
    #
    # # TODO: Combine these two?
    # if features.playViewsOnly and not (_.string.startsWith(document.location.pathname, '/play') or document.location.pathname is '/admin')
    #   delete window.alreadyLoadedView
    #   return @navigate('/play', { trigger: true, replace: true })
    # if features.playOnly and not /^(views)?\/?play/.test(path)
    #   delete window.alreadyLoadedView
    #   path = 'play/CampaignView'

    # path = "views/#{path}" if not _.string.startsWith(path, 'views/')
    # console.log path
    viewPromiseFn().then (ViewClass) =>
      console.log "Got a thing?", ViewClass
      # if not ViewClass and application.moduleLoader.load(path)
      #   @listenToOnce application.moduleLoader, 'load-complete', ->
      #     options.recursive = true
      #     @routeDirectly(path, args, options)
      #   return
      # return go((->`import(/* webpackChunkName: "views/NotFoundView" */ 'views/NotFoundView')`)) if not ViewClass
      view = new ViewClass(options, args...)  # options, then any path fragment args
      view.render()
      if window.alreadyLoadedView
        console.log "Need to merge view"
        delete window.alreadyLoadedView
        @mergeView(view)
      else
        @openView(view)
    
      # @viewLoad.setView(view)
      # @viewLoad.record()
    .catch (err) ->
      console.log err

  redirectHome: ->
    delete window.alreadyLoadedView
    homeUrl = switch
      when me.isStudent() then '/students'
      when me.isTeacher() then '/teachers'
      else '/'
    @navigate(homeUrl, {trigger: true, replace: true})

  tryToLoadModule: (path) ->
    # TODO: Put this back? Commented for easier Webpack debugging, not sure what it's for.
    # try
    path = path.match(/(views\/)?(.*)/)[2] # Chop out 'view' at beginning if it's there
    # return require('../views/' + path + '.coffee') # This hints Webpack to include things from /app/views/
    # catch error
      # if error.toString().search('Cannot find module "' + path + '" from') is -1
        # throw error

  openView: (view) ->
    @closeCurrentView()
    $('#page-container').empty().append view.el
    @activateTab()
    @didOpenView view

  mergeView: (view) ->
    unless view.mergeWithPrerendered?
      return @openView(view)

    target = $('#page-container>div')
    view.mergeWithPrerendered target
    view.setElement target[0]
    @didOpenView view

  didOpenView: (view) ->
    window.currentView = view
    view.afterInsert()
    view.didReappear()
    @path = document.location.pathname + document.location.search
    console.log "Did-Load-Route"
    @trigger 'did-load-route'

  closeCurrentView: ->
    if window.currentView?.reloadOnClose
      return document.location.reload()
    window.currentModal?.hide?()
    return unless window.currentView?
    window.currentView.destroy()
    $('.popover').popover 'hide'
    $('#flying-focus').css({top: 0, left: 0}) # otherwise it might make the page unnecessarily tall
    _.delay (->
      $('html')[0].scrollTop = 0
      $('body')[0].scrollTop = 0
    ), 10

  initializeSocialMediaServices: ->
    return if application.testing or application.demoing
    application.facebookHandler.loadAPI()
    application.gplusHandler.loadAPI()
    require('./services/twitter')()

  renderSocialButtons: =>
    # TODO: Refactor remaining services to Handlers, use loadAPI success callback
    @initializeSocialMediaServices()
    $('.share-buttons, .partner-badges').addClass('fade-in').delay(10000).removeClass('fade-in', 5000)
    application.facebookHandler.renderButtons()
    application.gplusHandler.renderButtons()
    twttr?.widgets?.load?()

  activateTab: ->
    base = _.string.words(document.location.pathname[1..], '/')[0]
    $("ul.nav li.#{base}").addClass('active')

  _trackPageView: ->
    window.tracker?.trackPageView()

  onNavigate: (e, recursive=false) ->
    @viewLoad = new ViewLoadTimer() unless recursive
    if _.isString e.viewClass
      ViewClass = @tryToLoadModule e.viewClass
      if not ViewClass and application.moduleLoader.load(e.viewClass)
        @listenToOnce application.moduleLoader, 'load-complete', ->
          @onNavigate(e, true)
        return
      e.viewClass = ViewClass

    manualView = e.view or e.viewClass
    if (e.route is document.location.pathname) and not manualView
      return document.location.reload()
    @navigate e.route, {trigger: not manualView}
    @_trackPageView()
    return unless manualView
    if e.viewClass
      args = e.viewArgs or []
      view = new e.viewClass(args...)
      view.render()
      @openView view
      @viewLoad.setView(view)
    else
      @openView e.view
      @viewLoad.setView(e.view)
    @viewLoad.record()

  navigate: (fragment, options) ->
    super fragment, options
    Backbone.Mediator.publish 'router:navigated', route: fragment

  reload: ->
    document.location.reload()

  logout: ->
    me.logout()
    @navigate('/', { trigger: true })
