module.exports = function(grunt){
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.initConfig({
        coffee:{
            glob_to_multiple: {
                expand: true,
                flatten: true,
                src: ['coffee/*.coffee'],
                dest: 'js',
                ext: '.js'
            },
        },
        watch: {
            coffee: {
                files: ['coffee/*.coffee'],
                tasks: 'coffee'
            }
        }
    });
    grunt.registerTask('default',[
        'coffee', 'watch'
    ]);
}
