let 
  addPrefix = message: "use-mysql: ${message}";
in{
  up = { port, datadir, package, runInBackground ? false }:
    (let 
      portString = builtins.toString port;
      version = package.version;
      serverName = "mysqld-${version}";
      # --socket=${datadir}/mysql.sock
    in ''
      function startDB(){
          mkdir -p ${datadir}
          local opts="--datadir=${datadir} --port=${portString} --socket=$2"
          local shouldInit=$1
          
          if $shouldInit; then
            opts="$opts --initialize --console"
          fi
          
          ${package}/bin/mysqld $opts 
      }

      # Don't exit with error, otherwise direnv won't load the environment
      function main(){
          local sockPath=''${XDG_RUNTIME_DIR:-/tmp}/mysqld
          mkdir -p $sockPath
          local sockFile=$sockPath/mysql-${portString}-${version}.sock
          local lockFile=$sockFile.lock
          
          shopt -s expand_aliases
          export alias mysql="mysql --socket=$sockFile"

          if [[ -f $lockFile ]]; then
             echo ${addPrefix "${serverName} already running at port ${portString}"};
             exit
          fi

          (if [[ -d ${datadir} ]]; then
              startDB false $sockFile
          else
              startDB true $sockFile
          fi) || {
                  echo ${addPrefix "${serverName} initialization failed"};
                  exit;
              }

          echo ${addPrefix "${serverName} created for port ${portString}"};
      }
                
      main
    '');

  # No viable solution for stopping the DB automatically right now
  # down = ''
    # echo "stopping mysql"
  # '';
}
