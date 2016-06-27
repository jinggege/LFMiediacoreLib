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
				ExternalInterface.call("console.log","[Flash_log]:",args);
			}catch(error:Error){}
			
			args = null;
		}
		
		
	}
}