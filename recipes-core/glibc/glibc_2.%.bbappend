CACHED_CONFIGUREVARS += " \
     libc_cv_ssp_strong=yes \
     libc_cv_ssp=yes \
"

do_install:append(){
       rm -f ${D}${bindir}/sprof
}
