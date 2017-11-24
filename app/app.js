(function () {
    'use strict';

    angular.module('app', ['ui.router']) .config(config)
    .run(run);

    function config($stateProvider, $urlRouterProvider) {
        // default route
        $urlRouterProvider.otherwise("/");

        $stateProvider
            .state('home', {
                url: '/',
                templateUrl: 'home/index.html',
                controller: 'homeController',
                data: { activeTab: 'home' }
            })
    }

    function run($http, $rootScope, $window) {
        // add JWT token as default auth header
        $http.defaults.headers.common['Authorization'] = 'Bearer ' + $window.jwtToken;

        // update active tab on state change
        $rootScope.$on('$stateChangeSuccess', function (event, toState, toParams, fromState, fromParams) {
            $rootScope.activeTab = toState.data.activeTab;
        });
    }

    // manually bootstrap angular after the JWT token is retrieved from the server
    $(function () {
        // get JWT token from server
        $.get('/app/token', function (token) {
            window.jwtToken = token.token;
            angular.bootstrap(document, ['app']);
        });
    });

    $(document).ready(function(){
        
            $('#scroll-top-div').on('click', function (e) {
                e.preventDefault();
                $('html,body').animate({
                    scrollTop: 0
                }, 700);
            });
        
        });
        
        
        jQuery(window).on('load',function() {
            jQuery(".cube-wrapper").delay(3000).fadeOut();
            jQuery(".preloader-body").delay(4000).fadeOut();
        })
})();
