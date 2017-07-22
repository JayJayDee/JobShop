var gulp = require('gulp');
var coffee = require('gulp-coffee');
var clean = require('gulp-clean');
var mocha = require('gulp-mocha');
var apidoc = require('gulp-apidoc');
var runseq = require('run-sequence');
var del = require('del')
var spawn = require('child_process').spawn

var paths = {
  ejs_src: 'src/views/**/*.ejs',
  ejs_bin: 'bin/views',
  coffee: 'src/**/*.coffee',
  front_coffee: 'front_src/**/*.coffee',
  front_bin: 'asset/js',
  js_src: 'src/**/*.js',
  js_bin: 'bin/**/*.js',
  test_case: 'test/**/*.coffee'
};

var node;
gulp.task('server', function() {
  if (node) node.kill();
  node = spawn('node', ['bin/app.js'], {stdio: 'inherit'});
  node.on('close', function(code) {
    if (code === 8) {
      gulp.log('Error detected, waiting for changes...');
    }
  });
});

gulp.task('token-test', function() {
  if (node) node.kill();
  node = spawn('node', ['bin/app.js', 'test'], {stdio: 'inherit'});
  node.on('close', function(code) {
    if (code === 8) {
      gulp.log('Error detected, waiting for changes...');
    }
  });
});


process.on('exit', function() {
    if (node) node.kill();
});

gulp.task('copy-ejs', function() {
  return gulp.src(paths.ejs_src).pipe(gulp.dest(paths.ejs_bin));
});

gulp.task('compile-coffee', function() {
  return gulp.src(paths.coffee)
    .pipe(coffee({bare: true}).on('error', console.log))
    .pipe(gulp.dest('./bin'));
});

gulp.task('compile-coffee-front', function() {
  return gulp.src(paths.front_coffee)
    .pipe(coffee({bare: true}).on('error', console.log))
    .pipe(gulp.dest(paths.front_bin));
});

gulp.task('remove-js-src', function() {
  return gulp.src(paths.js_src)
    .pipe(clean());
});

gulp.task('remove-js-bin', function(cb) {
  var stream = del([paths.js_bin]).then(function(result) {
    cb();
  });
});

gulp.task('rebuild-coffee-all', function(cb) {
  runseq('remove-js-bin', 'compile-coffee', 'remove-js-src', function() {
    cb();
  });
});

gulp.task('gen-apidoc', function(cb) {
  apidoc({
      src: './src',
      dest: './doc'
  }, cb);
});


gulp.task('test', function(cb) {
  var options = {
    ui: 'bdd',
    reporter: 'nyan',  
    bail: true ,
    compilers: 'coffee:coffee-script'
  };
  require('coffee-script/register');
  return gulp.src(paths.test_case).pipe(mocha(options));
}); 

gulp.task('default', function(cb) {
  runseq('rebuild-coffee-all', 'copy-ejs', 'compile-coffee-front', 'test', 'server');
  gulp.watch(paths.coffee, function() {
    runseq('compile-coffee', 'test', 'server', function(error) {
    });
  });

  gulp.watch(paths.ejs_src, function() {
    runseq('copy-ejs', function(err) {
    });
  });

  gulp.watch(paths.test_case, function() {
    runseq('test', function(error) {
    });
  });

  gulp.watch(paths.front_coffee, function() {
    runseq('compile-coffee-front', function(err) {
    });
  });
});