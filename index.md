---
layout: page
title: 志不强者智不达
tagline: Supporting tagline
---
{% include JB/setup %}

#### 索引
博文:
<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>
分类:
<ul>
        {% assign categories_list = site.categories %}  
        {% include JB/categories_list %}
</ul>
标签:
<ul>
  	  {% assign tags_list = site.tags %}  
  	  {% include JB/tags_list %}
</ul>
