package lf.media.core.data
{
	public class StatusConfig
	{
		/**错误状态*/
		public static const STATUS_ERROR                     :String  = "STATUS_ERROR";
		/**1：获取调度地址成功 2:获取播放地址成功*/
		public static const STATUS_GET_URL_SUCCESS:String  ="STATUS_GET_URL_SUCCESS";
		/**get play list fail*/
		public static const STAUS_GETPLAYLIST_FAIL:String = "STAUS_GETPLAYLIST_FAIL";
		/**metadata*/
		public static const STATUS_ONMETADATA         :String = "STATUS_ONMETADATA";
		/**流状态*/
		public static const STATUS_STREAM                   :String = "STATUS_STREAM";
		/**界面数据初始化完毕*/
		public static const STATUS_INIT_COMPLETE      :String = "STATUS_INIT_COMPLETE";
		/**播放状态:0:未直播 1:直播中*/
		public static const STATUS_ROOM                        :String  = "STATUS_ROOM";
		/**未直播状态*/
		public static const STATUS_ROOM_END               :int = 0;
		/**直播中*/
		public static const STATUS_ROOM_LIVING          :int = 1;
		/**调度地址请求成功*/
		public static const STATUS_STEP_1                      :int = 1;
		/**播放地址地址请求成功*/
		public static const STATUS_STEP_2                      :int = 2;
		
		/**流类型   flv rtmp  p2p*/
		public static const STAEAM_TYPE_HTTP             :String = "STAEAM_TYPE_HTTP";
		public static const STAEAM_TYPE_P2P                :String = "STAEAM_TYPE_P2P";
		
	}
}