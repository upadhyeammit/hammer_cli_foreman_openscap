module HammerCLIForemanOpenscap
  class ExceptionHandler < HammerCLIForeman::ExceptionHandler
    def mappings
      [
        [RestClient::InternalServerError, :handle_internal_error],
        [RestClient::UnprocessableEntity, :handle_unprocessable_entity],
        [HammerCLIForemanOpenscap::DownloadError, :handle_download_error]
      ] + super
    end

    protected

    def handle_download_error(e)
      print_error e.message
      log_full_error e
    end

    def handle_internal_error(e)
      handle_scap_error(e)
      HammerCLI::EX_SOFTWARE
    end

    def handle_unprocessable_entity(e)
      handle_scap_error(e)
      HammerCLI::EX_DATAERR
    end

    def handle_scap_error(e)
      response = JSON.parse(e.response)
      response = HammerCLIForeman.record_to_common_format(response)
      print_error(response["message"] || response["full_messages"])
      log_full_error e
    end
  end
end
