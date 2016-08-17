package lf.media.core.util
{
	import flash.events.StatusEvent;
	import flash.external.ExternalInterface;
	import flash.net.LocalConnection;
	
	/**
	 * 打印log 到控制台
	 */
	public class Console
	{
		
		public static var isDebug:Boolean = false;
		
		
		public static function log(...args):void
		{
			if(!isDebug) return;
			try{
				var date:Date = new Date();
				var time:String = date.getHours()+":"+date.getMinutes()+":"+date.getSeconds()+":"+date.getMilliseconds();
				ExternalInterface.call("console.log","[Flash_log "+time+"]:",args);
				date = null;
			}catch(error:Error){}
			
			args = null;
		}
		
		
	}
}