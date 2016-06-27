package lf.media.core.video
{
	public class CallbackData
	{
		
		
		public var callbackType:String = "";
		public var data:Object = null;
		
		public function CallbackData(callbackType:String,data:Object){
			this.callbackType = callbackType;
			this.data                = data;
		}
		
		
		
		
	}
}