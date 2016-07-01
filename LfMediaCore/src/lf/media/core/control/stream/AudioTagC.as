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
		
		
		/** return 0:是video tag   1:不是video tag   2：数据不够*/
		public function get  isAudio():int{
			if(_sourceB.bytesAvailable<_at.headLen){
				return 2;
			}
			
			_buffer.position = 0;
			if(_buffer.bytesAvailable<_at.headLen){
				_sourceB.readBytes(_buffer,_buffer.bytesAvailable,_at.headLen-_buffer.bytesAvailable);
			}
			var flag:Boolean = _buffer.readByte() == 0x08;
			_buffer.position = 0;
			return flag? 0:1;
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
			_buffer.position = 0;
			//print();
			return _at;
		}
		
		
		public function print():void{
			var str:String = "s data=";
			for(var i:int=0; i<10; i++){
				str += _buffer[i].toString(16)+"|";
			}
			_buffer.position = 0;
			trace(str);
			
			var str1:String = "e data=";
			for(i=_buffer.length-10; i<_buffer.length; i++){
				str1 += _buffer[i].toString(16)+"|";
			}
			_buffer.position = 0;
			trace(str1);
			
		}
		
		
		
		private var _sourceB:URLStream = null;
		private var _buffer:ByteArray = null;
		private var _at:AudioTag = new AudioTag();
		
		
	}
}