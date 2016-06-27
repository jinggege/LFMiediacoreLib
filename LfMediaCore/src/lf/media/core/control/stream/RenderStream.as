package lf.media.core.control.stream
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class RenderStream extends Sprite
	{
		public function RenderStream()
		{
			init();
		}
		
		private function init():void{
			
			this.addChild(_video);
			
			var conn:NetConnection = new NetConnection();
			conn.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
			conn.connect(null);
			
			ns = new NetStream(conn);
			ns.client = {onMetaData:onMetaData};
			ns.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
			ns.bufferTime = 1;
			ns.bufferTimeMax = 500;
			_video.attachNetStream(ns);
			
			ns.play(null);
		}
		
		
		private function onMetaData(info:Object):void{
				trace(info);
		}
		
		private function netStatusHandler(event:NetStatusEvent):void{
			trace(event.info.code);
		}
		
		
		private var _video:Video = new Video(500,450);
		public var ns:NetStream = null;
		
		
	}
}