require 'json'

module Jekyll
  class GymPageGenerator < Generator
    safe true
    priority :normal

    def generate(site)
      items = load_json(site, '_rawdata/gym.json')

      Jekyll.logger.info "GymGenerator:", "#{items.size}개 헬스장 페이지 생성 중..."
      items.each do |c|
        next if c['slug'].to_s.strip.empty?
        site.pages << GymPage.new(site, c)
      end

      Jekyll.logger.info "GymGenerator:", "완료 (#{items.size}개)"
    end

    private

    def load_json(site, path)
      file = File.join(site.source, path)
      return [] unless File.exist?(file)
      JSON.parse(File.read(file, encoding: 'utf-8'))
    rescue => e
      Jekyll.logger.warn "GymGenerator:", "#{path} 로드 실패: #{e.message}"
      []
    end
  end

  class GymPage < Page
    def initialize(site, c)
      @site = site
      @base = site.source
      @dir  = "gym/#{c['slug']}"
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(@base, '_layouts'), 'gym.html')
      self.data.merge!(c)
      self.data['layout']      = 'gym'
      self.data['title']       = build_title(c)
      self.data['description'] = build_desc(c)
    end

    private

    def build_title(c)
      loc = [c['doShort'], c['sigungu']].compact.join(' ')
      "#{c['storeName']} #{loc} 위치 전화번호"
    end

    def build_desc(c)
      loc = [c['doShort'], c['sigungu']].compact.join(' ')
      "#{loc} #{c['storeName']}의 위치, 전화번호를 확인하세요."[0, 155]
    end
  end
end
