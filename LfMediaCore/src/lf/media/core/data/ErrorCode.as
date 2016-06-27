package lf.media.core.data
{
	public class ErrorCode
	{
		/**获得调度列表失败( io 错误引发)*/
		public static const ERROR_1000:String  ="1000"; 
		/**获得调度列表失败( 安全沙箱 错误引发)*/
		public static const ERROR_1001:String  ="1001"; 
		/**获得调度列表成功 但JSON 格式 过程错误*/
		public static const ERROR_1002:String  ="1002";  
		/**获得播放地址失败( io 错误引发)*/
		public static const ERROR_2000:String = "2000"; 
		/**获得播放地址失败( 安全沙箱 错误引发)*/
		public static const ERROR_2001:String = "2001"; 
		/**获取播放地址成功 但JSON 格式 过程错误*/
		public static const ERROR_2002:String = "2002"; 
		/**流不存在  但  房间是直播状态      */
		public static const ERROR_3000:String = "3000"; 
		/**失败(服务器逻辑)      */
		public static const ERROR_1:String = "1"; 
		/**无效参数(服务器逻辑)      */
		public static const ERROR_2:String = "2";
		/**流已过期(服务器逻辑)      */
		public static const ERROR_3:String = "3";
		/**服务器内部错误      */
		public static const ERROR_4:String = "4";
		/**验证无效      */
		public static const ERROR_5:String = "5";
		
		
		public static function getErrorMsg(errorCode:String):String{
			switch(errorCode){
				case ERROR_1000:
					return "获得调度列表失败( io 错误引发)";
				case ERROR_1002:
					return "获得调度列表成功 但JSON 格式 过程错误";
				case ERROR_2000:
					return "获得播放地址失败( io 错误引发)";
				case ERROR_2001:
					return "获得播放地址失败( 安全沙箱 错误引发)";
				case ERROR_2002:
					return "获取播放地址成功 但JSON 格式 过程错误";
				case ERROR_3000:
					return "流不存在或流播放失败";
				case ERROR_1:
					return "获取调度地址失败(服务器逻辑)";
				case ERROR_2:
					return "无效参数(服务器逻辑)";
				case ERROR_3:
					return "流已过期(服务器逻辑)";
				case ERROR_4:
					return "服务器内部错误";
				case ERROR_5:
					return "验证无效";
				default:
					return "服务器内部错误";
			}
			
			return "";
		}
		
		
		
		
	}
}