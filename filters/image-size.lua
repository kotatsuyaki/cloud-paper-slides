local bigimages = {}

local meta_filter = {
    Meta = function(meta)
        bigimages = meta.bigimages
        return meta
    end,
}

local image_filter = {
    Image = function(elem)
        local attr = elem.attr
        if bigimages:find_if(function(arr)
            return arr[1].text == elem.src
        end) then
            print('Setting image to small:', elem.src)
            attr.attributes['width'] = '80%'
        else
            attr.attributes['width'] = '60%'
        end
        return pandoc.Image(elem.caption, elem.src, elem.title, attr)
    end,
}

return { meta_filter, image_filter }
