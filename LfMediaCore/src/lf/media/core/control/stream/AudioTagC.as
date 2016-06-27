package lf.media.core.control.stream
{
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import lf.media.core.model.flv.AudioTag;
	
	
	public class AudioTagC
	{
		public function AudioTagC()
		{
		}
		
		
		public function init(sourceB:URLStream,buffer:ByteArray):void{
			this._buffer = buffer;
			this._sourceB = sourceB;
		}
		
		
		
		public function get  isAudio():Boolean{
			var str:String = "";
			if(_sourceB.bytesAvailable<_at.headLen){
				return false;
			}
			
			if(_buffer.bytesAvailable<_at.headLen){
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,_at.headLen-_buffer.bytesAvailable);
			}
			var fStr:String = _buffer[0].toString(16);
			return fStr == "8";
		}
		
		
		public function get tagData():AudioTag{
			var b:ByteArray = new ByteArray();
			_at.size = (_buffer[1] << 16) | (_buffer[2] << 8) | (_buffer[3]); 
			
			if(_buffer.bytesAvailable< _at.tagLen){
				
				if(_sourceB.bytesAvailable < _at.tagLen){
					_at.data = null;
					return _at;
				}
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,_at.tagLen-_buffer.bytesAvailable);
			}
			
			_buffer.position = 0;
			_buffer.readBytes(b,0,_at.tagLen);
			_at.data = b;
			_buffer.position = _at.tagLen;
			return _at;
		}
		
		
		
		
		private var _sourceB:URLStream = null;
		private var _buffer:ByteArray = null;
		private var _at:AudioTag = new AudioTag();
		
		
	}
}