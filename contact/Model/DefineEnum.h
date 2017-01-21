#ifndef _DEFINEENUM_
#define _DEFINEENUM_

#define PARSE_NULL_STR(nsstr) nsstr ? nsstr : @""

#define CONSTRAINT_UPLOAD_IMAGE_SIZE 1024.0f
#define CONSTRAINT_UPLOAD_IMAGE_QUALITY 0.8f

#define HTTP_REQUEST_TIME_OUT_SECONDS 60	//download or upload timeout seconds

#define BIG_AVATAR_SIZE 780


//修改联系人信息时的数据
typedef enum{
    //
    kMoDefault,
    //电话
	kMoTel =0x01,				
    //邮箱
	kMoMail=0x02,				
    //网址 个人主页
	kMoUrl = 0x03,			
    //人员  关系	
	kMoPerson=0x04,			
    //地址
	kMoAdr = 0x05,			
    //纪念日
	kMoBday=0x06,	
	
    //即时通讯
	kMoInstantMessage = 0x10,
	kMoIm91U,			//91U
	kMoImQQ,				//QQ
	kMoImMSN,				//msn
	kMoImICQ,				//ICQ
	kMoImGtalk,				//Gtalk
	kMoImYahoo,				//yahoo
	kMoImSkype,				//skype
	kMoImAIM,				//aim
	kMoImJabber,			//jabber
    kMoImWeChat,            //微信
    
	//联系人分组
	kMoCategory = 0x20,			//联系人分组
    
    //contact
	kMoContactID = 0x40,		//ID
	kMoFirstName,			//名字
	kMoLastName,			//姓
	kMoOrganization,		//公司   //学校
	kMoDepartment,			//部门
	kMoNote,				//备注  //简介
	kMoBirthday,			//生日
	kMoJobTitle,			//职称
	kMoNickName,			//昵称
	kMoMiddleName,			//中间名称
    
	
	//注册名
	kMoRegisterName = 0x50,
	//居住地
	kMoResidence,
	//性别
	kMoGender,
	//生肖
	kMoAnimalSign,
	//星座
	kMoZodiac,	
	
	//头像
	kMoimage = 0x80			//头像图片
}_contactType;

#define kMoCommonType kMoDefault
typedef int ContactType;

typedef enum {
    // 邮箱 地址 电话 IM
    kMoLabelHomeType = 0x0000 // 住宅
    , kMoLabelWorkType          // 工作
    , kMoLabelOtherType         // 其他
    
    // 电话
    , kMoTelLabelCellType = 0x0010 // 手机
    , kMoTelLabelHomeFaxType // 住宅传真
    , kMoTelLabelWorkFaxType // 工作传真
    , kMoTelLabelPagerType // 传呼机
    , kMoTelLabelCarType   // 车载电话
    , kMoTelLabelIPhoneType // IPHone手机
    , kMoTelLabelMainTyp    // 主要
    
    // URL
    , kMoUrlLabelHomepageType = 0x0020  // 个人主页
    , kMoUrlLabelFtpType   // FTP
    , kMoUrlLabelBlogType   // 个人博客
    , kMoUrlProfileType     // 个人页面
    
    // 日期
    , kMoDateLabelAnniversaryType = 0x0030 // 纪念日
    
    // 相关人
    , kMoRelatedNameLabelSpouseType = 0x0040 // 配偶
    , kMoRelatedNameLabelChildType  // 小孩
    , kMoRelatedNameLabelFatherType // 父亲
    , kMoRelatedNameLabelMotherType // 母亲
    , kMoRelatedNameLabelParentType // 父母亲
    , kMoRelatedNameLabelBrotherType // 兄弟
    , kMoRelatedNameLabelSisterType // 姐妹
    , kMoRelatedNameLabelFriendType // 朋友
    , kMoRelatedNameLabelRelativeType // 亲戚
    , kMoRelatedNameLabelDomestic_partnerType // 国内合作伙伴
    , kMoRelatedNameLabelManagerType // 领导
    , kMoRelatedNameLabelAssistantType // 助理
    , kMoRelatedNameLabelPartnerType // 合伙人
    , kMoRelatedNameLabelReferred_byType // 
}_labelType;
typedef int LabelType;



#endif

