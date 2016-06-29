package lf.media.core.control.stream
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import lf.media.core.model.flv.AudioTag;
	import lf.media.core.model.flv.HeadTag;
	import lf.media.core.model.flv.MetdataTag;
	import lf.media.core.model.flv.VideoTag;
	
	
	public class LFStream extends EventDispatcher
	{
		/**事件:IO 错误*/
		public static const E_ERR_IO:String=  "E_ERR_IO";
		/**事件:安全沙箱 错误*/
		public static const E_ERR_SECURITY:String = "E_ERR_SECURITY";
		/**事件:下载流结束*/
		public static const E_STREAM_COMPLETE:String = "E_STREAM_COMPLETE";
		/**事件:下载流进行中*/
		public static const E_STREAM_PROGRESS:String = "E_STREAM_PROGRESS";
		
		
		private const MAX_BUFFER:int =3;
		
		private const ClearCatchLimitSize:int = 20000;
		private const ClearCathLimitBufferLen:int = 2;  //7  最优
		
		private const firstRead:int = 1;
		
		private var _tiker:Timer = new Timer(0);
		private var _delayT:Timer = new Timer(0);
		
		public function LFStream(target:IEventDispatcher=null)
		{
			super(target);
			_urlStream.addEventListener(ProgressEvent.PROGRESS,progressHandler);
			_urlStream.addEventListener(Event.COMPLETE,completeHandler);
			_urlStream.addEventListener(IOErrorEvent.IO_ERROR,ioerrorHandler);
			_urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityerrorHandler);
			_tiker.addEventListener(TimerEvent.TIMER,rendHandler);
			_delayT.addEventListener(TimerEvent.TIMER,checkDelayHandler);
		}
		
		
		public function start(url:String):void{
			_url = url;
			_urlStream.load(new URLRequest(url))
			_tiker.start();
			_delayT.start();
			
			_flvHeadC.init(_urlStream,_buffer);
			_metdataC.init(_urlStream,_buffer);
			_audioTagC.init(_urlStream,_buffer);
			_videoTagC.init(_urlStream,_buffer);
			_isFrist = true;
		}
		
		
		public function reStart(url:String):void{
			this.reset();
			_urlStream.load(new URLRequest(url))
			_tiker.start();
		}
		
		
		public function setNetStream(netStream:NetStream):void{
			_netStream = netStream;
		}
		
		private function progressHandler(event:ProgressEvent):void{
			trace(" init data===",_urlStream.bytesAvailable);
			//this.dispatchEvent(new Event(E_STREAM_PROGRESS));
		}
		
		
		private function completeHandler(event:Event):void{
			this.dispatchEvent(new Event(E_STREAM_COMPLETE));
		}
		
		
		private function ioerrorHandler(event:ErrorEvent):void{
			this.dispatchEvent(new Event(E_ERR_IO));
		}
		
		private function securityerrorHandler(event:SecurityErrorEvent):void{
			this.dispatchEvent(new Event(E_ERR_SECURITY));
		}
		
		
		private var _delay:Number = 0;
		private var _cc:int = 0;
		private function checkDelayHandler(event:TimerEvent):void{
			_delay = _delay==0? getTimer() : _delay;
			_cc = getTimer() - _delay;
			_delay = getTimer();
		}
		
		
		
		private var _once:Boolean = false;
		
		private function rendHandler(event:TimerEvent):void{
			if(_netStream == null) return;
			
			inCatch(firstRead);
			if(_urlStream.bytesAvailable<11) return;
			if(_isFrist){
				appendFlvHead();
				appendMetdata();
				_isFrist = false;
			}
			
			if(_netStream.bufferLength > ClearCathLimitBufferLen){
				var dt:int = 0
				while(dt<2){
					clearAudioCatch();
					clearVideoCatch()
					dt++;
					trace("=============丢数据");
					trace("=============丢数据");
					trace("=============丢数据");
					trace("=============丢数据");
					trace("=============丢数据");
					trace("=============丢数据");
				}
				
			}
			
			
			if(!_once){
				//_buffer.position = 0;
				//_buffer.writeByte(1);
				//_buffer.position = 0;
				//_once = true;
			}
			
			
			var _t:int = 0;
			var forCount:int = 0;
			forCount = _cc>50? 40 : 2;
			
			trace("=====AV=",_urlStream.bytesAvailable);
			while(_t<forCount){
				var isA:Boolean = appendAudioTag();
				trace("A=",_urlStream.bytesAvailable);
				var isV:Boolean = appendVideoTag();
				trace("V=",_urlStream.bytesAvailable);
				if(!isA && !isV){
					clearBadTag();
					//this.reStart(_url);
				}
				_t++;
			}
			
			 
			 trace("buffer len=",_netStream.bufferLength);
			 trace("======================",_urlStream.bytesAvailable);
		}
		
		
		
		private function appendFlvHead():void{
			var isHead:Boolean = _flvHeadC.isFlvHead;
			if(isHead){
				var ht:HeadTag = _flvHeadC.tagData;
				_netStream.appendBytes(ht.data);
				ht.destroy();
				_buffer.clear();
			}
		}
		
		
		private function appendMetdata():void{
			var isMetdata:Boolean = _metdataC.isMetdata;
			if(isMetdata){
				var mt:MetdataTag = _metdataC.tagData;
				_netStream.appendBytes(mt.data);
				mt.destroy();
				_buffer.clear();
			}
		}
		
		private function appendAudioTag():Boolean{
			var isAudio:Boolean = _audioTagC.isAudio;
			if(isAudio){
				var at:AudioTag = _audioTagC.tagData;
				if( at.data){
					_netStream.appendBytes(at.data);
					at.destroy();
					_buffer.clear();
				}
			}
			
			return isAudio;
		}
		
		
		private function appendVideoTag():Boolean{
			var isVideo:Boolean = _videoTagC.isVideo;
			if(isVideo){
				var vt:VideoTag = _videoTagC.tagData;
				if(vt.data){
					if(_netStream.bufferLength<ClearCathLimitBufferLen){
						_netStream.appendBytes(vt.data);
					}
						vt.destroy();
						vt = null;
						_buffer.clear();
				}
				
			}
			
			return isVideo;
		}
		
		private function appendKeyVideoTag():void{
			var isVideo:Boolean = _videoTagC.isVideo;
			if(isVideo){
				var vt:VideoTag = _videoTagC.tagData;
				//vt.print();
				if(vt.data){
					if(vt.keyType==0x17){
						//_netStream.appendBytes(vt.data);
					}
					vt.destroy();
					vt = null;
					_buffer.clear();
				}
			}
		}
		
		private function clearAudioCatch():void{
			var isAudio:Boolean = _audioTagC.isAudio;
			if(isAudio){
				var at:AudioTag = _audioTagC.tagData;
				if( at.data){
					at.destroy();
					_buffer.clear();
				}
				
				at = null;
			}
		}
		
		
		/**
		 * 清除视频缓冲 ：只清除普通帧
		 */
		private function clearVideoCatch():void{
			var isVideo:Boolean = _videoTagC.isVideo;
			if(isVideo){
				var vt:VideoTag = _videoTagC.tagData;
				if(vt.data){
					if(vt.keyType==0x17){
						//_netStream.appendBytes(vt.data);
					}
					vt.destroy();
					_buffer.clear();
				}
				vt = null;
			}
		}
		
		
		/**
		 * 清除坏包
		 */
		private function clearBadTag():void{
			
			trace("xxxxxxxxxx 脏数据");
			trace("xxxxxxxxxx 脏数据");
			trace("xxxxxxxxxx 脏数据");
			trace("xxxxxxxxxx 脏数据");
			
			
			var index:int = 0;
			while(index<_buffer.length){
				_buffer.position = index;
				
				if(_buffer.readByte()==0x09){
					
					if(index+11 >_buffer.length){
						_urlStream.readBytes(_buffer,_buffer.length,(index+11-_buffer.length+1));
					}
					
					
					var frameType:uint = 0;
					_buffer.position = index+11;
					frameType = _buffer.readByte();
					_buffer.position = index;
					
					if(frameType==0x17 || frameType==0x27){
						var b:ByteArray = new ByteArray();
						_buffer.position = index;
						_buffer.readBytes(b,0,_buffer.length-index);
						_buffer.clear();
						b.position = 0;
						b.readBytes(_buffer,0,b.bytesAvailable);
						b.clear();
						b = null;
						return;
					}
				}
				
				index++;
				
			}
			
		}
		
		
		private function inCatch(readLen:int):void{
			if(_urlStream.bytesAvailable<firstRead ) return;
			if(_buffer.bytesAvailable==0){
				_urlStream.readBytes(_buffer,0,readLen);
			}
		}
		
		
		
		public function reset():void{
			_isFrist = true;
			_tiker.stop();
			_buffer.clear();
			if(_urlStream.connected){
				_urlStream.close();
			}
		}
		
		
		
		public function destroy():void{
			
			if(_tiker){
				_tiker.stop();
				_tiker = null;
			}
			
			if(_buffer){
				_buffer.clear();
				_buffer = null;
			}
			
			if(_urlStream){
				_urlStream.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
				_urlStream.removeEventListener(Event.COMPLETE,completeHandler);
				_urlStream.removeEventListener(IOErrorEvent.IO_ERROR,ioerrorHandler);
				_urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,securityerrorHandler);
			}
		
		}
		
		
		
		
		
		private var _urlStream:URLStream = new URLStream();
		private var _buffer:ByteArray = new ByteArray();
		private var _netStream:NetStream;
		private var _readEnd:Boolean = false;
		private var _flvHeadC:FlvHeadTagC = new FlvHeadTagC();
		private var _metdataC:MetdataTagC = new MetdataTagC();
		private var _audioTagC:AudioTagC = new AudioTagC();
		private var _videoTagC:VideoTagC = new VideoTagC();
		private var _sourceB:ByteArray = new ByteArray();
		private var _isFrist:Boolean = true;
		private var _url:String = "";
		
		
		
	}
}