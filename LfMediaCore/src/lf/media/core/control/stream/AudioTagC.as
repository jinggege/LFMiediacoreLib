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
			
			_buffer.position = 0;
			
			if(_buffer.bytesAvailable<_at.headLen){
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,_at.headLen-_buffer.bytesAvailable);
			}
			var flag:Boolean = _buffer.readByte() == 0x08;
			_buffer.position = 0;
			return flag;
		}
		
		
		public function get tagData():AudioTag{
			var b:ByteArray = new ByteArray();
			_at.size = (_buffer[1] << 16) | (_buffer[2] << 8) | (_buffer[3]); 
			
			if(_buffer.bytesAvailable< _at.tagLen){
				
				if(_sourceB.bytesAvailable < _at.tagLen){
					
					//_sourceB.readBytes(b,0,_sourceB.bytesAvailable);
					//b.clear();
					//b = null;
					//_buffer.clear();
					_at.data = null;
					return _at;
				}
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,_at.tagLen-_buffer.bytesAvailable);
			}
			
			_buffer.position = 0;
			_buffer.readBytes(b,0,_at.tagLen);
			_at.data = b;
			//_buffer.position = _at.tagLen;
			_buffer.clear();
			_buffer.position = 0;
			return _at;
		}
		
		
		
		
		private var _sourceB:URLStream = null;
		private var _buffer:ByteArray = null;
		private var _at:AudioTag = new AudioTag();
		
		
	}
}