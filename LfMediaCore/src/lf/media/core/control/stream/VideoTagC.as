package lf.media.core.control.stream
{
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import lf.media.core.model.flv.VideoTag;
	
	
	public class VideoTagC
	{
		public function VideoTagC()
		{
		}
		
		
		public function init(sourceB:URLStream,buffer:ByteArray):void{
			this._buffer = buffer;
			this._sourceB = sourceB;
		}
		
		
		
		public function get  isVideo():Boolean{
			var str:String = "";
			if(_buffer.bytesAvailable<_vt.headLen){
				
				if(_sourceB.bytesAvailable<_vt.headLen){
					return false;
				}
				
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,_vt.headLen-_buffer.bytesAvailable);
			}
			var fStr:String = _buffer[0].toString(16);
			return fStr == "9";
		}
		
		
		public function get tagData():VideoTag{
			var b:ByteArray = new ByteArray();
			_vt.size = (_buffer[1] << 16) | (_buffer[2] << 8) | (_buffer[3]);  
			
			if(_sourceB.bytesAvailable < _vt.tagLen){
				_vt.data = null;
				return _vt;
			}
			
			if(_buffer.bytesAvailable< _vt.tagLen){
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,_vt.tagLen-_buffer.bytesAvailable);
			}
			_vt.keyType = _buffer[11].toString(16);
			
			_buffer.position = 0;
			_buffer.readBytes(b,0,_vt.tagLen);
			_vt.data = b;
			_buffer.position = _vt.tagLen;
			return _vt;
		}
		
		
		
		
		private var _sourceB:URLStream = null;
		private var _buffer:ByteArray = null;
		private var _vt:VideoTag = new VideoTag();
		
		
	}
}