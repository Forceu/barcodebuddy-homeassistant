bashio::log.info "Initialize the barcode buddy configuration..."

BBUDDY_DISABLE_AUTHENTICATION=$(bashio::config "disable_auth")

CMD ["/app/supervisor"]
