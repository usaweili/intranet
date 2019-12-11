require 'open-uri'
namespace :josh do
  desc "Create News and fetch it's details with nokogiri"
  task :import_news => :environment do
    create_news
    fetch_and_update_news_details
    explicitly_add_image_url
  end

  def create_news
    news_data.each do |news|
      News.find_or_create_by(link: news[:link], date: news[:date].to_date)
    end
  end

  def fetch_and_update_news_details
    News.all.each do |news|
      @document = Nokogiri::HTML.parse(open(news.link, 'User-Agent' => 'firefox'))
      news.title = @document.title
      news.image_url = image_url
      news.description = description
      news.save
    end
  end

  def description
    content = ['description', "og:description", "twitter:description", 'Description'].map{ |name|
      @document.at("meta[name='#{name}']")
    }
    content.compact.present? ? content.compact.first['content'] : ""
  end

  def image_url
    content = ["og:image", "twitter:image"].map{ |name|
      ['name', 'property'].map{|attr_name| @document.at("meta[#{attr_name}='#{name}']") }
    }.flatten
    content.compact.present? ? content.compact.first['content'] : ""
  end

  def explicitly_add_image_url
    news_with_no_image.each do |data|
      news = News.find_by(link: data[:link])
      if news
        news.update(image_url: data[:image_url])
      end
    end
  end

  def news_with_no_image
    [
      {
        link: "https://www.indiatechonline.com/special-feature.php?id=451.php",
        image_url: "https://josh-website.s3.ap-south-1.amazonaws.com/Media/evolution-of-wearable-technology-in-sports-451.jpg"
      },
      {
        link: "https://www.indiatechonline.com/special-feature.php?id=434.php",
        image_url: "https://josh-website.s3.ap-south-1.amazonaws.com/Media/chatbots-are-the-next-health-assistants-434.jpg"
      },
      {
        link: "https://www.indiatechonline.com/special-feature.php?id=392.php",
        image_url: "https://josh-website.s3.ap-south-1.amazonaws.com/Media/the-case-for-open-source-392.jpg"
      },
      {
        link: "https://yourstory.com/mystory/487a9ce310-know-it-before-you-embrace-open-source",
        image_url: "https://josh-website.s3.ap-south-1.amazonaws.com/Media/know-it-before-you-embrace-open.png"
      }
    ]
  end

  def news_data
    [
      {:link=>"https://www.sakaltimes.com/opinion/swalekhan-empowering-visually-impaired-write-42830", :date=>"10 Nov 2019"},
      {:link=>"https://www.indiatechonline.com/special-feature.php?id=451.php", :date=>"15 April 2019"},
      {:link=>"https://yourstory.com/2019/04/how-banks-and-financial-institutions-are-shifting-", :date=>"3 April 2019"},
      {:link=>"https://www.indiatechonline.com/special-feature.php?id=434.php", :date=>"26 Nov 2018"},
      {:link=>"https://yourstory.com/2018/11/age-alexa-siri-chatbots-next-health-assistants", :date=>"14 Nov 2018"},
      {:link=>"https://www.hindustantimes.com/pune-news/father-s-day-special-no-place-higher-than-on-your-daddy-s-shoulders/story-OONSRjhhRrgU59NBKacezN.html", :date=>"17 June 2018"},
      {:link=>"https://yourstory.com/2018/06/machine-learning-manufacturing-downtime-efficiency", :date=>"11 June 2018"},
      {:link=>"https://www.sakaltimes.com/pune/around-2000-docs-using-digital-prescriptions-across-country-18074", :date=>"16 May 2018"},
      {:link=>"https://www.indiatechonline.com/special-feature.php?id=392.php", :date=>"8 Dec 2017"},
      {:link=>"https://www.firstpost.com/tech/news-analysis/startups-stand-to-benefit-most-from-open-source-technologies-by-understanding-it-before-embracing-it-4239439.html", :date=>"3 Dec 2017"},
      {:link=>"https://timesofindia.indiatimes.com/city/pune/tackling-food-wastage-the-it-way/articleshow/58841541.cms", :date=>"26 May 2017"},
      {:link=>"https://indianexpress.com/article/india/as-global-turmoil-reaches-pune-citys-it-hub-rocked-by-layoffs-4665907/", :date=>"21 May 2017"},
      {:link=>"https://yourstory.com/mystory/487a9ce310-know-it-before-you-embrace-open-source", :date=>"15 March 2017"},
      {:link=>"https://indianexpress.com/article/cities/pune/is-pune-ready-to-go-cashless-demonetisation-new-year-4453807/", :date=>"1 Jan 2017"},
      {:link=>"https://tech.economictimes.indiatimes.com/news/corporate/tech-companies-think-out-of-the-box-to-hire-the-best-from-campuses/54909324", :date=>"24 October 2016"},
      {:link=>"https://health.cxotv.news/2016/08/10/the-paediatric-network-providing-technological-benefits-to-the-healthcare-sector-of-india", :date=>"10 August 2016"},
      {:link=>"https://issuu.com/thegoldensparrow/docs/tgs_broadsheet_pages_july_30_pdf_fo/11", :date=>"30 July 2016"},
      {:link=>"https://economictimes.indiatimes.com/tech/software/goodwill-is-the-source-code-at-this-open-coder-collective/articleshow/53070730.cms", :date=>"6 July 2016"},
      {:link=>"https://www.thehansindia.com/posts/index/Education-and-Careers/2015-06-25/Importance-of-Programming-in-todays-Academia/159351", :date=>"25 June 2015"},
      {:link=>"https://www.ciol.com/open-source-application-combat-infant-mortality-rates-india/?fbclid=IwAR1w_23vIjNd81z_D3i2rZSt9V7IhB-RDzcoDBFdVrPg4tXRMSqTCYGXsKI", :date=>"19 Dec 2014"},
      {:link=>"https://www.thehindubusinessline.com/info-tech/start-up-develops-neonatal-nutrition-calculator-for-premature-babies/article23110624.ece", :date=>"2 Dec 2014"}
    ]
  end
end
