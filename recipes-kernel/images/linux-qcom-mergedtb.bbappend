inherit deploy

# Add deploy task after do_install
do_deploy() {
    install -m 0644 ${B}/DTOverlays/combined-dtb.dtb ${DEPLOY_DIR_IMAGE}
}

addtask do_deploy after do_install
