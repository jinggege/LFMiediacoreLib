package lf.media.core.component.loader
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import lf.media.core.util.Console;
	
	/**
	 * param:加载图片
	 * param:返回图片 和 url
	 */
	public class SimpleImgLoader extends EventDispatcher
	{
		
		private var _loader:Loader;
		private var _callback:Function;
		private var _url:String = "";
		
		public function SimpleImgLoader()
		{
		
		}
		
		/**
		 * 取图片
		 * @param url: url:图片路径  callback:回调
		 * @param return {url:图片url,content:图片实体}
		 */
		public function getImg(url:String,callback:Function):void
		{
			_callback = callback;
			_url          = url;
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadCompleteHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			_loader.load(new URLRequest(url));
		}
		
		
		private function loadCompleteHandler(event:Event):void
		{
			
			//todo  奇怪  此处 callback在线上不会被调用  原因不明
			data["content"] = _loader.content;
			data["url"] = _url;
			_callback.call(null,data);
		}
		
		
		
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			Console.log("io err");
			_callback.call(null,null);
		}
		
		
		public function destroy():void
		{
			Console.log("destroy");
			if(_loader == null) return;
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadCompleteHandler);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			_loader.unloadAndStop(true);
			_loader = null;
		}
		
		
		public var data:Object = {};
		
		
		
		
	}
}