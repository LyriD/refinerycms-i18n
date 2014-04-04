module RoutingFilter
  class RefineryLocales < Filter

    def around_recognize(path, env, &block)
      if request.host_with_port == 'ybw.dev.maniaco.ru:3000'
          ::I18n.locale = :en
        else
          ::I18n.locale = ::Refinery::I18n.default_frontend_locale
      end

      yield.tap do |params|
        params[:locale] = ::I18n.locale if ::Refinery::I18n.enabled?
      end
    end

    def around_generate(params, &block)
      locale = params.delete(:locale) || ::I18n.locale

      yield.tap do |result|
        result = result.is_a?(Array) ? result.first : result
        if ::Refinery::I18n.url_filter_enabled? and !::Refinery::I18n.domain_name_enabled? and
           locale != ::Refinery::I18n.default_frontend_locale and
           result !~ %r{^/(#{Refinery::Core.backend_route}|wymiframe)}
          result.sub!(%r(^(http.?://[^/]*)?(.*))) { "#{$1}/#{locale}#{$2}" }
        end
      end
    end

  end
end
