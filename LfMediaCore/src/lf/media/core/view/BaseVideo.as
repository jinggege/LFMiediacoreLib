package lf.media.core.view
{
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	
	import lf.media.core.data.InitOption;
	import lf.media.core.data.LiveCoreData;
	import lf.media.core.data.LiveCoreDataV2;
	import lf.media.core.data.PlayOption;
	import lf.media.core.data.StatusConfig;
	import lf.media.core.event.LfEvent;
	import lf.media.core.video.CallbackData;
	import lf.media.core.video.CallbackType;
	import lf.media.core.video.LfNomalVideo;
	
	public class BaseVideo extends Sprite
	{
		
		private var _coreData:LiveCoreDataV2;
		private var _cVideo:LfNomalVideo;
		public function BaseVideo()
		{
			super();
			_coreData = new LiveCoreDataV2();
			
			_coreData = new LiveCoreDataV2();
			_coreData.addEventListener(StatusConfig.STATUS_ERROR,errorHandler);
			_coreData.addEventListener(StatusConfig.STATUS_GET_URL_SUCCESS,getStreamCompleteHandler);
			//_coreData.addEventListener(StatusConfig.STATUS_INIT_COMPLETE,getTitlesCompleteHandler);
			
			
			var initOption:InitOption = new InitOption({appId:101,roomId:300})
			_coreData.init(initOption);
			playOption.sessionId = initOption.sessionId;
			
			
			var playOption:PlayOption = new PlayOption();
			
			playOption.alias = "xxxx";
			playOption.token = "xxx";
			
			_coreData.play(playOption);
		}
		
		
		private function getStreamCompleteHandler(event:LfEvent):void{
			
			_cVideo = new LfNomalVideo(callbackByVideo);
			_cVideo.creat(null);
			
			_cVideo.netStream.bufferTime        =1;
			_cVideo.netStream.bufferTimeMax =10 ;
			_cVideo.netStream.inBufferSeek      = true;
			_cVideo.netStream.removeEventListener(NetStatusEvent.NET_STATUS,netStartHandler);
			_cVideo.netStream.addEventListener(NetStatusEvent.NET_STATUS,netStartHandler);
			_cVideo.play(_coreData.getStreamUrl());
		}
		
		private function netStartHandler(event:NetStatusEvent):void{
			callbackByVideo(new CallbackData(event.info.code,event))
		}
		
		
		
		private function callbackByVideo(data:CallbackData):void{
			
			trace("NetStatus=",data.callbackType,"  data=",data.data);
			
			switch(data.callbackType){
				case "NetStream.Play.StreamNotFound" :
					break;
				case "NetStream.Play.Start":
					break;
				case "NetStream.Play.Stop":
					break;
				case "NetStream.Buffer.Full":
					break;
				case "NetStream.Buffer.Empty":
					
					break;
				case "NetStream.Seek.InvalidTime":
					
					break;
				case "NetStream.Buffer.Flush":
					break;
				
				case "NetStream.Play.InsufficientBW":
					break;
				case "NetStream.Play.NoSupportedTrackFound":
					break;
				
				case "NetStream.Play.Failed" :
					break;
				
				case CallbackType.CT_ONMETADATA :
					_cVideo.width=data.data["width"]
					_cVideo.height = data.data["height"]
					
					break
				
				
				case IOErrorEvent.IO_ERROR:
					break
				
				default:
					
					break;
			}
		}
		
		
		
		
		private function errorHandler(event:LfEvent):void{
		
		}
		
		
		
	}
}