

## 三、hooks useRequest

```js
import {useRequest} from 'alita';

const getHerolist = async () => {
  const data = await queryHerolist();
  return data;
}

useEffect(() => {
  const { data, error, loading } = useRequest(getHerolist, {
    url: '',
  });
}, [])
```


const [a,seta]=useState([]);
useEffect(() => {
  const { data, error, loading } = await getHerolist;
  seta(data)
}, [])

const { data:a, error, loading } = useRequest(getHerolist);



