{% if theme.cnzz_siteid %}

  <div>
    <div style="display:inline-block; vertical-align: middle;">
        <script type="text/javascript">var cnzz_protocol = (("https:" == document.location.protocol) ? " https://" : " http://");document.write(unescape("%3Cspan id='cnzz_stat_icon_1273289170'%3E%3C/span%3E%3Cscript src='" + cnzz_protocol + "s19.cnzz.com/z_stat.php%3Fid%3D1273289170%26show%3Dpic' type='text/javascript'%3E%3C/script%3E"));</script>
    </div>

    {% if config.icp_id %}
    <span class="post-meta-divider"></span>
    <div style="display:inline-block;">
    <a href="http://www.miitbeian.gov.cn/">{{config.icp_id}}</a>
    </div>
    {% endif %}
    <span class="post-meta-divider"></span>
    <div style="display:inline-block;">
        <img src="/images/beian.png" style="display: inline-block;vertical-align:middle;margin:0px,5px,5px,0px;"/>
        <a href="http://www.beian.gov.cn/portal/registerSystemInfo?recordcode=13010802000830">冀公网安备 13010802000830号</a>
    </div>
  </div>

{% endif %}
