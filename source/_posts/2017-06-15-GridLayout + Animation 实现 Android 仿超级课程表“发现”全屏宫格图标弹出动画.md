---
layout:     post
title:      "GridLayout + Animation 实现 Android 仿超级课程表“发现”全屏宫格图标弹出动画"
subtitle:   ""
date:       2017-06-15 22:41:00
author:     "James"
header-img: "img/post-bg-android.jpg"
catalog: true
tags: [Android]
---

<p><font size="3">关于</font><font size="6">全屏宫格图标</font><font size="3">，超级课程表的“发现”是目前我见过的最好的解决方案，流畅的动画打破了布局单一带来的死板气氛。下面就来介绍这样的动画是如何实现的。</font></p><p><br></p><p><font size="3">首先创建一个activity叫BiaoDiscoverActivity</font></p><p><font size="3">此处用到了Handler，<font style="NoForceAllFonts By Microsoft YaHei&quot;,HighLevelEmoji,&quot;Catcat520.Lite.Latin&quot;,&quot;SDF.TypeSetCtrlFonts&quot;,&quot;SDF.CnSymbol&quot;,&quot;SDF.EnSymbol&quot;,&quot;SDF.Number&quot;,此处填写英文字体,&quot;此处填写 font-family 的名称&quot;,&quot;Envy Code R&quot;,Inconsolata,&quot;Envy Code R&quot;,&quot;Open Sans&quot;,Roboto,&quot;Segoe UI&quot;,&quot;Helvetica Neue&quot;,&quot;Lucida Grande&quot;,Ubuntu,Tahoma,Verdana,Menlo,Monaco,此处填写中文字体,&quot;SDF.FixScTcFonts&quot;,&quot;SDF.Hangul&quot;,&quot;Microsoft YaHei&quot;,&quot;Microsoft YaHei&quot;,&quot;Microsoft JhengHei&quot;,&quot;Microsoft YaHei UI&quot;,&quot;Microsoft JhengHei UI&quot;,fp-font,AccessibilityFoundicons,&quot;Accessibility Foundicons&quot;,anchorjs-icons,brandico,Brandico,brankic1979,Brankic1979,&quot;brankic 1979&quot;,&quot;Brankic 1979&quot;,broccolidry,Broccolidry,bundlestars,chagaan,CONDENSEicon,cuticons,Cuticons,dashicons,duotai,duotai-status,&quot;Dot Com&quot;,ecoico,Ecoico,EightiesShades,ElegantIcons,elusive,Elusive,Elusive-Icons,entypo,Entypo,&quot;Entypo Social&quot;,Entypo-Social,&quot;Erler Dingbats&quot;,et-line,Et-line,FabricMDL2Icons,feedfont,fontawesome,FontAwesome,fontelico,Fontelico,fontello,Fontello,Garqag,GeneralEnclosedFoundicons,&quot;General Enclosed Foundicons&quot;,GeneralFoundicons,&quot;General Foundicons&quot;,Gibson,&quot;Gibson Light&quot;,gibson_lightbold,Gibson_lightbold,gibson_lightitalic,Gibson_lightitalic,gibsonregular,Gibsonregular,&quot;Glyphicons Halflings&quot;,&quot;GLYPHICONS Halflings&quot;,&quot;Heydings Controls&quot;,&quot;Heydings Icons&quot;,icft_temai,icft_temai_index,iconminia,Iconminia,iconvault,Iconvault,icomoon,Icomoon,iconfont,iconfont-tcl,iconic,Iconic,icons,Icons,ifanrx,iknow-qb_share_icons,&quot;Just Vector&quot;,JustVector,JustVectorRegular,LenovoSupport,linecons,Linecons,lobi-pc,LondonMM,londonmmregular,Londonmmregular,mainicon,maki,Maki,Mainicon,&quot;Material Icons Extended&quot;,Material-Design-Icons,MENKSOF0,Menksoft2007,Menksoft2012,MenksoftQagan,meteocons,Meteocons,MeteoconsRegular,mfglabs,Mfglabs,&quot;MFG Labs Iconset&quot;,mfg_labs_iconsetregular,Mfg_labs_iconsetregular,modernpics,Modernpics,&quot;Modern Pictograms&quot;,o365Icons,Office365Icons,&quot;OpenWeb Icons&quot;,PulsarJS,RaphaelIcons,rondo,Rondo,sellerCenter,sdp-icons,silkcons,Silkcons,SocialFoundicons,&quot;Social Foundicons&quot;,Socialico,&quot;Socialico Plus&quot;,&quot;Social Networking Icons&quot;,Sosa,&quot;Symbol Signs&quot;,&quot;Symbol Signs Basis set&quot;,typicons,Typicons,VideoJS,weathercons,Weathercons,websymbols,Websymbols,&quot;Web Symbols&quot;,&quot;Web Symbols Liga&quot;,wpzoom,Wpzoom,Yglyphs-legacy,youkuMobile,zocial,Zocial,&quot;PingFang SC&quot;,&quot;PingFang TC&quot;,&quot;PingFang HK&quot;,&quot;Noto Sans CJK SC&quot;,&quot;Noto Sans CJK TC&quot;,&quot;Noto Sans CJK JP&quot;,&quot;Source Han Sans SC&quot;,&quot;Source Han Sans TC&quot;,&quot;Source Han Sans&quot;,SimSun,LowLevelEmoji,&quot;Segoe UI Symbol&quot;,&quot;Segoe UI Historic&quot;,Symbola,Quivira,Meiryo,&quot;Malgun Gothic&quot;,NSimSun,MingLiU,MingLiU_HKSCS,SimSun-ExtB,MingLiU-ExtB,MingLiU_HKSCS-ExtB,&quot;Nimbus Roman No9 L&quot;,&quot;WenQuanYi Micro Hei&quot;,&quot;WenQuanYi Zen Hei&quot;,&quot;Droid Sans Fallback&quot;,&quot;Hiragino Sans GB&quot;,Symbol,FZSongS,&quot;Simsun (Founder Extended)&quot;,&quot;Microsoft Himalaya&quot;,&quot;Microsoft New Tai Lue&quot;,&quot;Microsoft PhagsPa&quot;,&quot;Microsoft Tai Le&quot;,&quot;Microsoft Uighur&quot;,&quot;Microsoft Yi Baiti&quot;,&quot;Mongolian Baiti&quot;,&quot;Estrangelo Edessa&quot;,Ebrima,Euphemia,Nyala,&quot;Plantagenet Cherokee&quot;,sylfaen,&quot;Arial Unicode MS&quot;,Code2000,HanaMinA,HanaMinB,Unifont; text-indent:28px" face="&quot;" color="#333333">Handler主要用于异步消息的处理：当发出一个消息之后，首先进入一个消息队列，发送消息的函数即刻返回，而另外一个部分在消息队列中逐一将消息取出，然后对消息进行处理，也就是发送消息和接收消息不是同步的处理。 这种机制通常用来处理相对耗时比较长的操作</font></font></p><p><br></p><pre name="code" class="java">public class BiaoDiscoverActivity extends BaseActivity {

	@Bind(R.id.ivBiaoClose)
	ImageView mIvClose;
	@Bind(R.id.rll_found_note)
	AutoRelativeLayout mrllNote;
	@Bind(R.id.rll_found_exam_time)
	AutoRelativeLayout mrllExamTime;
	@Bind(R.id.rll_found_class_room_search)
	AutoRelativeLayout mrllClassroom;
	@Bind(R.id.rll_found_score_search)
	AutoRelativeLayout mrllScore;
	@Bind(R.id.rll_found_super_act)
	AutoRelativeLayout mrllSuperAct;
	@Bind(R.id.rll_found_super_group)
	AutoRelativeLayout mrllSuperGroup;
	@Bind(R.id.rll_found_train_tickets)
	AutoRelativeLayout mrllTrainTickets;
	@Bind(R.id.rll_found_air_tickets)
	AutoRelativeLayout mrllAirTickets;
	@Bind(R.id.rll_found_school_recuit)
	AutoRelativeLayout mrllSchoolRecuit;
	@Bind(R.id.rll_found_house_rent)
	AutoRelativeLayout mrllHouseRent;
	@Bind(R.id.rll_found_entertainment_class)
	AutoRelativeLayout mrllEntertainment;

	//宫格图标
	private List&lt;AutoRelativeLayout&gt; rllList;
	private Handler handler;

	@Override
	protected BasePresenter createPresenter() {
		return null;
	}

	@Override
	protected int provideContentViewId() {
		return R.layout.activity_biao_discover;
	}


	@Override
	public void initView() {
		super.initView();
		initRll();
		initGrid();
		handler = new Handler();
	}

	private synchronized void initRll() {
		rllList = new ArrayList&lt;&gt;();
		rllList.add(mrllNote);
		rllList.add(mrllExamTime);
		rllList.add(mrllClassroom);
		rllList.add(mrllScore);
		rllList.add(mrllSuperAct);
		rllList.add(mrllSuperGroup);
		rllList.add(mrllTrainTickets);
		rllList.add(mrllAirTickets);
		rllList.add(mrllSchoolRecuit);
		rllList.add(mrllHouseRent);
		rllList.add(mrllEntertainment);
	}

	@Override
	protected void onResume() {
		super.onResume();
		itemsAnimation();
	}

	private void initGrid() {
		for (int i = 0; i &lt; rllList.size(); i++) {
			int finalI = i;
			//先全部隐藏
			rllList.get(finalI).setVisibility(View.GONE);
		}
	}

	private void itemsAnimation() {
		handler.postDelayed(new Runnable() {
			@Override
			public void run() {
				for (int i = 0; i &lt; rllList.size(); i++) {
					int finalI = i;
					//先全部隐藏
					rllList.get(finalI).setAlpha(0);
					rllList.get(finalI).setVisibility(View.VISIBLE);
				}
				for (int i = 0; i &lt; rllList.size(); i++) {
					int finalI = i;
					handler.postDelayed(new Runnable() {
						@Override
						public void run() {
							//设置透明度为全不透明
							rllList.get(finalI).setAlpha(1);
							//再执行动画
							rllList.get(finalI).startAnimation(AnimationUtils.loadAnimation(BiaoDiscoverActivity.this, R.anim.grid_items_scale));
						}
					}, 0 + i * 30);
				}
			}
		}, 200);

	}

	@Override
	public void initListener() {
		super.initListener();
		mIvClose.setOnClickListener(v -&gt; {
			finish();
			exitAct();
		});
		mrllClassroom.setOnClickListener(v -&gt; jumpToWebViewActivity(AppConst.H5_CLASSROOM_SEARCH));
		mrllScore.setOnClickListener(v -&gt; jumpToWebViewActivity(AppConst.H5_SCORE_RESULT_SEARCH));
		mrllSuperGroup.setOnClickListener(v -&gt; jumpToWebViewActivity(AppConst.H5_SUPER_GROUP));
		mrllTrainTickets.setOnClickListener(v -&gt; jumpToWebViewActivity(AppConst.H5_TRAIN_BUS_TICKETS));
		mrllSchoolRecuit.setOnClickListener(v -&gt; jumpToWebViewActivity(AppConst.H5_SCHOOL_RECUIT));
		mrllAirTickets.setOnClickListener(v -&gt; jumpToWebViewActivity(AppConst.H5_AIR_TICKETS));
		mrllHouseRent.setOnClickListener(v -&gt; jumpToWebViewActivity(AppConst.H5_HOUSE_RENT));
		mrllEntertainment.setOnClickListener(v -&gt; jumpToWebViewActivity(AppConst.H5_ENTERTAINMANIT_CLASS));
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			finish();
			exitAct();
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}

	private void exitAct() {
		UIUtils.startWindowAnimation(this, R.anim.window_as_pop_fade_in, R.anim.window_as_pop_fade_out);
	}
}</pre><p></p><p><br></p><font size="3">其父类为一个抽象类BaseActivity,子类中的各个重写方法在父类中的执行顺序如下</font><p><br></p><p></p><pre name="code" class="java">protected void onCreate(@Nullable Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(provideContentViewId());
		ButterKnife.bind(this);

		initView();
		initListener();
		initData();

	}</pre><p></p><p><br></p><font size="3">这样，只需在子类中重写provideContentViewId()方法，返回子类的content布局资源文件的值就可以了，子类不再需要设置布局ID，也不再需要每次调用ButterKnife.bind()</font><p><br></p><p><font size="6">下面是重点</font></p><p><font size="3">宫格布局的实现</font></p><p><font size="3">以下是BiaoDiscoverActivity的布局资源文件</font></p><p><font size="3">首先向 zhy 的 AutoLayout 表示感谢</font></p><p></p><pre name="code" class="html">&lt;?xml version="1.0" encoding="utf-8"?&gt;
&lt;com.zhy.autolayout.AutoRelativeLayout
	xmlns:android="http://schemas.android.com/apk/res/android"
	android:layout_width="match_parent"
	android:layout_height="match_parent"&gt;

	&lt;com.zhy.autolayout.AutoRelativeLayout
		xmlns:android="http://schemas.android.com/apk/res/android"
		android:layout_width="match_parent"
		android:layout_height="wrap_content"
		android:background="@drawable/ic_found_bg"
		android:paddingBottom="@dimen/biao_discover_root_padding_bottom"
		android:paddingTop="@dimen/biao_discover_root_padding_top"
		&gt;

		&lt;include
			layout="@layout/include_toolbar"
			android:visibility="gone"
			/&gt;

		&lt;GridLayout
			android:layout_width="match_parent"
			android:layout_height="match_parent"
			android:layout_alignParentTop="true"
			android:layout_centerHorizontal="true"
			android:layout_gravity="center_horizontal"
			android:columnCount="3"
			android:rowCount="4"&gt;


			&lt;com.zhy.autolayout.AutoRelativeLayout
				android:id="@+id/rll_found_note"
				android:layout_width="wrap_content"
				android:layout_column="0"
				android:layout_columnWeight="1"
				android:layout_row="0"
				android:layout_rowWeight="1"
				android:visibility="visible"
				&gt;

				&lt;ImageView
					android:id="@+id/imageView3"
					android:layout_width="wrap_content"
					android:layout_height="@dimen/biao_discover_item_iv_height"
					android:src="@drawable/ic_found_note_icon"
					android:layout_centerVertical="true"
					android:layout_centerHorizontal="true"/&gt;

				&lt;TextView
					android:layout_width="wrap_content"
					android:layout_height="wrap_content"
					android:layout_below="@+id/imageView3"
					android:layout_centerHorizontal="true"
					android:layout_marginTop="@dimen/biao_discover_item_tv_margin_top"
					android:text="@string/biao_note"
					android:textColor="@color/gray2"
					android:textSize="@dimen/biao_discover_item_tv_text_size"/&gt;
			&lt;/com.zhy.autolayout.AutoRelativeLayout&gt;


			&lt;com.zhy.autolayout.AutoRelativeLayout
				android:id="@+id/rll_found_exam_time"
				android:layout_width="wrap_content"
				android:layout_column="1"
				android:layout_columnWeight="1"
				android:layout_row="0"
				android:layout_rowWeight="1"
				android:visibility="visible"
				&gt;

				&lt;ImageView
					android:id="@+id/imageView4"
					android:layout_width="wrap_content"
					android:layout_height="@dimen/biao_discover_item_iv_height"
					android:src="@drawable/ic_found_countdown_icon"
					android:layout_centerVertical="true"
					android:layout_centerHorizontal="true"/&gt;

				&lt;TextView
					android:layout_width="wrap_content"
					android:layout_height="wrap_content"
					android:layout_below="@+id/imageView4"
					android:layout_centerHorizontal="true"
					android:layout_marginTop="@dimen/biao_discover_item_tv_margin_top"
					android:text="@string/biao_exam_time"
					android:textColor="@color/gray2"
					android:textSize="@dimen/biao_discover_item_tv_text_size"/&gt;
			&lt;/com.zhy.autolayout.AutoRelativeLayout&gt;

			&lt;com.zhy.autolayout.AutoRelativeLayout
				android:id="@+id/rll_found_class_room_search"
				android:layout_width="wrap_content"
				android:layout_column="2"
				android:layout_columnWeight="1"
				android:layout_row="0"
				android:layout_rowWeight="1"
				android:visibility="visible"
				&gt;

				&lt;ImageView
					android:id="@+id/imageView5"
					android:layout_width="wrap_content"
					android:layout_height="@dimen/biao_discover_item_iv_height"
					android:src="@drawable/ic_found_room_search"
					android:layout_centerVertical="true"
					android:layout_centerHorizontal="true"/&gt;

				&lt;TextView
					android:layout_width="wrap_content"
					android:layout_height="wrap_content"
					android:layout_below="@+id/imageView5"
					android:layout_centerHorizontal="true"
					android:layout_marginTop="@dimen/biao_discover_item_tv_margin_top"
					android:text="@string/biao_classroom_search"
					android:textColor="@color/gray2"
					android:textSize="@dimen/biao_discover_item_tv_text_size"/&gt;
			&lt;/com.zhy.autolayout.AutoRelativeLayout&gt;

			&lt;com.zhy.autolayout.AutoRelativeLayout
				android:id="@+id/rll_found_score_search"
				android:layout_width="wrap_content"
				android:layout_column="0"
				android:layout_columnWeight="1"
				android:layout_row="1"
				android:layout_rowWeight="1"
				android:visibility="visible"
				&gt;

				&lt;ImageView
					android:id="@+id/imageView6"
					android:layout_width="wrap_content"
					android:layout_height="@dimen/biao_discover_item_iv_height"
					android:src="@drawable/ic_found_score_search"
					android:layout_centerVertical="true"
					android:layout_centerHorizontal="true"/&gt;

				&lt;TextView
					android:layout_width="wrap_content"
					android:layout_height="wrap_content"
					android:layout_below="@+id/imageView6"
					android:layout_centerHorizontal="true"
					android:layout_marginTop="@dimen/biao_discover_item_tv_margin_top"
					android:text="@string/biao_score_search"
					android:textColor="@color/gray2"
					android:textSize="@dimen/biao_discover_item_tv_text_size"/&gt;
			&lt;/com.zhy.autolayout.AutoRelativeLayout&gt;

			&lt;com.zhy.autolayout.AutoRelativeLayout
				android:id="@+id/rll_found_super_act"
				android:layout_width="wrap_content"
				android:layout_column="1"
				android:layout_columnWeight="1"
				android:layout_row="1"
				android:layout_rowWeight="1"
				android:visibility="visible"
				&gt;

				&lt;ImageView
					android:id="@+id/imageView7"
					android:layout_width="wrap_content"
					android:layout_height="@dimen/biao_discover_item_iv_height"
					android:src="@drawable/ic_found_super_act"
					android:layout_centerVertical="true"
					android:layout_centerHorizontal="true"/&gt;

				&lt;TextView
					android:layout_width="wrap_content"
					android:layout_height="wrap_content"
					android:layout_below="@+id/imageView7"
					android:layout_centerHorizontal="true"
					android:layout_marginTop="@dimen/biao_discover_item_tv_margin_top"
					android:text="@string/biao_super_act"
					android:textColor="@color/gray2"
					android:textSize="@dimen/biao_discover_item_tv_text_size"/&gt;
			&lt;/com.zhy.autolayout.AutoRelativeLayout&gt;

			&lt;com.zhy.autolayout.AutoRelativeLayout
				android:id="@+id/rll_found_super_group"
				android:layout_width="wrap_content"
				android:layout_column="2"
				android:layout_columnWeight="1"
				android:layout_row="1"
				android:layout_rowWeight="1"
				android:visibility="visible"
				&gt;

				&lt;ImageView
					android:id="@+id/imageView8"
					android:layout_width="wrap_content"
					android:layout_height="@dimen/biao_discover_item_iv_height"
					android:src="@drawable/ic_found_super_group"
					android:layout_centerVertical="true"
					android:layout_centerHorizontal="true"/&gt;

				&lt;TextView
					android:layout_width="wrap_content"
					android:layout_height="wrap_content"
					android:layout_below="@+id/imageView8"
					android:layout_centerHorizontal="true"
					android:layout_marginTop="@dimen/biao_discover_item_tv_margin_top"
					android:text="@string/biao_super_group"
					android:textColor="@color/gray2"
					android:textSize="@dimen/biao_discover_item_tv_text_size"/&gt;
			&lt;/com.zhy.autolayout.AutoRelativeLayout&gt;

			&lt;com.zhy.autolayout.AutoRelativeLayout
				android:id="@+id/rll_found_train_tickets"
				android:layout_width="wrap_content"
				android:layout_column="0"
				android:layout_columnWeight="1"
				android:layout_row="2"
				android:layout_rowWeight="1"
				android:visibility="visible"
				&gt;

				&lt;ImageView
					android:id="@+id/imageView9"
					android:layout_width="wrap_content"
					android:layout_height="@dimen/biao_discover_item_iv_height"
					android:src="@drawable/ic_found_bus"
					android:layout_centerVertical="true"
					android:layout_centerHorizontal="true"/&gt;

				&lt;TextView
					android:layout_width="wrap_content"
					android:layout_height="wrap_content"
					android:layout_below="@+id/imageView9"
					android:layout_centerHorizontal="true"
					android:layout_marginTop="@dimen/biao_discover_item_tv_margin_top"
					android:text="@string/biao_train_bus_tickets"
					android:textColor="@color/gray2"
					android:textSize="@dimen/biao_discover_item_tv_text_size"/&gt;
			&lt;/com.zhy.autolayout.AutoRelativeLayout&gt;

			&lt;com.zhy.autolayout.AutoRelativeLayout
				android:id="@+id/rll_found_air_tickets"
				android:layout_width="wrap_content"
				android:layout_column="1"
				android:layout_columnWeight="1"
				android:layout_row="2"
				android:layout_rowWeight="1"
				android:visibility="visible"
				&gt;

				&lt;ImageView
					android:id="@+id/imageView10"
					android:layout_width="wrap_content"
					android:layout_height="@dimen/biao_discover_item_iv_height"
					android:src="@drawable/ic_found_airplane"
					android:layout_centerVertical="true"
					android:layout_centerHorizontal="true"/&gt;

				&lt;TextView
					android:layout_width="wrap_content"
					android:layout_height="wrap_content"
					android:layout_below="@+id/imageView10"
					android:layout_centerHorizontal="true"
					android:layout_marginTop="@dimen/biao_discover_item_tv_margin_top"
					android:text="@string/biao_air_tickets"
					android:textColor="@color/gray2"
					android:textSize="@dimen/biao_discover_item_tv_text_size"/&gt;
			&lt;/com.zhy.autolayout.AutoRelativeLayout&gt;

			&lt;com.zhy.autolayout.AutoRelativeLayout
				android:id="@+id/rll_found_school_recuit"
				android:layout_width="wrap_content"
				android:layout_column="2"
				android:layout_columnWeight="1"
				android:layout_row="2"
				android:layout_rowWeight="1"
				android:visibility="visible"
				&gt;

				&lt;ImageView
					android:id="@+id/imageView11"
					android:layout_width="wrap_content"
					android:layout_height="@dimen/biao_discover_item_iv_height"
					android:src="@drawable/ic_found_school_recuit"
					android:layout_centerVertical="true"
					android:layout_centerHorizontal="true"/&gt;

				&lt;TextView
					android:layout_width="wrap_content"
					android:layout_height="wrap_content"
					android:layout_below="@+id/imageView11"
					android:layout_centerHorizontal="true"
					android:layout_marginTop="@dimen/biao_discover_item_tv_margin_top"
					android:text="@string/biao_school_recuit"
					android:textColor="@color/gray2"
					android:textSize="@dimen/biao_discover_item_tv_text_size"/&gt;
			&lt;/com.zhy.autolayout.AutoRelativeLayout&gt;

			&lt;com.zhy.autolayout.AutoRelativeLayout
				android:id="@+id/rll_found_house_rent"
				android:layout_width="wrap_content"
				android:layout_column="0"
				android:layout_columnWeight="1"
				android:layout_row="3"
				android:layout_rowWeight="1"
				android:visibility="visible"
				&gt;

				&lt;ImageView
					android:id="@+id/imageView12"
					android:layout_width="wrap_content"
					android:layout_height="@dimen/biao_discover_item_iv_height"
					android:src="@drawable/ic_found_rent_house"
					android:layout_centerVertical="true"
					android:layout_centerHorizontal="true"/&gt;

				&lt;TextView
					android:layout_width="wrap_content"
					android:layout_height="wrap_content"
					android:layout_below="@+id/imageView12"
					android:layout_centerHorizontal="true"
					android:layout_marginTop="@dimen/biao_discover_item_tv_margin_top"
					android:text="@string/biao_house_rent"
					android:textColor="@color/gray2"
					android:textSize="@dimen/biao_discover_item_tv_text_size"/&gt;
			&lt;/com.zhy.autolayout.AutoRelativeLayout&gt;

			&lt;com.zhy.autolayout.AutoRelativeLayout
				android:id="@+id/rll_found_entertainment_class"
				android:layout_width="wrap_content"
				android:layout_column="1"
				android:layout_columnWeight="1"
				android:layout_row="3"
				android:layout_rowWeight="1"
				android:visibility="visible"
				&gt;

				&lt;ImageView
					android:id="@+id/imageView13"
					android:layout_width="wrap_content"
					android:layout_height="@dimen/biao_discover_item_iv_height"
					android:src="@drawable/ic_found_entertainment_class"
					android:layout_centerVertical="true"
					android:layout_centerHorizontal="true"/&gt;

				&lt;TextView
					android:layout_width="wrap_content"
					android:layout_height="wrap_content"
					android:layout_below="@+id/imageView13"
					android:layout_centerHorizontal="true"
					android:layout_marginTop="@dimen/biao_discover_item_tv_margin_top"
					android:text="@string/biao_entertainment_class"
					android:textColor="@color/gray2"
					android:textSize="@dimen/biao_discover_item_tv_text_size"/&gt;
			&lt;/com.zhy.autolayout.AutoRelativeLayout&gt;
		&lt;/GridLayout&gt;
	&lt;/com.zhy.autolayout.AutoRelativeLayout&gt;

	&lt;ImageView
		android:id="@+id/ivBiaoClose"
		android:layout_width="90dp"
		android:layout_height="wrap_content"
		android:layout_alignParentBottom="true"
		android:layout_centerHorizontal="true"
		android:adjustViewBounds="true"
		android:src="@drawable/selector_found_close_btn"/&gt;
&lt;/com.zhy.autolayout.AutoRelativeLayout&gt;</pre><br><font size="3">这个宫格布局的实现方法不是唯一的，但以上实现方法可以保证95%以上的相似，以上用到的所有图标资源请自行搜索</font><p></p><p><font size="3">下面是实现后的效果</font></p><p><font size="3"><br></font></p><p><img src="http://img.blog.csdn.net/20170615223623150?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvemJsMTE0NjU1NjI5OA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast" _xhe_src="http://img.blog.csdn.net/20170615223623150?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvemJsMTE0NjU1NjI5OA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast" alt="" width="200" align="middle"><br></p><p><br></p><p><font size="3">需要注意的是，布局中的图标应避免处于父布局的边缘位置，因为执行动画过程中，尤其是缩放动画，超出父布局的部分不会显示</font></p><p><font size="3">图标的缩放动画在同样在XML文件中进行定义，这里用到了两个缩放动画，可以设置第二个动画开始时间偏移量为第一个动画的时长，这样可以使最终效果非常自然、连贯，此处加入一个透明度渐变动画，和原版更为贴近</font></p><p><font size="3"><br></font></p><p><font size="3"></font></p><pre name="code" class="html">&lt;?xml version="1.0" encoding="utf-8"?&gt;
&lt;set xmlns:android="http://schemas.android.com/apk/res/android"&gt;
	&lt;scale
		android:duration="75"
		android:fromXScale="0.5"
		android:fromYScale="0.5"
		android:interpolator="@android:anim/decelerate_interpolator"
		android:pivotX="50%"
		android:pivotY="50%"
		android:startOffset="0"
		android:toXScale="1"
		android:toYScale="1"/&gt;
	&lt;scale
		android:duration="75"
		android:fromXScale="1.2"
		android:fromYScale="1.2"
		android:interpolator="@android:anim/decelerate_interpolator"
		android:pivotX="50%"
		android:pivotY="50%"
		android:startOffset="75"
		android:toXScale="1"
		android:toYScale="1"/&gt;

	&lt;alpha
		android:duration="100"
		android:fromAlpha="0"
		android:toAlpha="1"/&gt;
&lt;/set&gt;</pre><br><p></p><p><font size="3">底部的关闭按钮用selector的形式定义，实现点击的效果</font></p><p><font size="3"><br></font></p><pre name="code" class="html">&lt;?xml version="1.0" encoding="utf-8"?&gt;
&lt;selector xmlns:android="http://schemas.android.com/apk/res/android"&gt;
	&lt;item android:drawable="@drawable/ic_found_close_press" android:state_pressed="true"/&gt;
	&lt;item android:drawable="@drawable/ic_found_close" android:state_enabled="false"/&gt;
&lt;/selector&gt;</pre><br><p></p><p><font size="3"><br></font></p><p><font size="3"><br></font></p><p><font size="3"><br></font></p><p><br></p>
